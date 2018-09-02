//
//  LXRouter.m
//  TestRouterLX
//
//  Created by Livespro on 2017/7/10.
//  Copyright © 2017年 Livespro. All rights reserved.
//

#import "LXRouter.h"
#import <objc/runtime.h>

void LXRouteMap(NSString *route){
    
    [[LXRouter shareRouter] routeMap:route animated:YES completion:nil];
}

//eg:通用设置 App-Prefs:root=General
#define kSystemUrlContainString @":root="

@interface LXRouter ()

@property (nonatomic, strong) NSMutableDictionary *lxStoreList;

@property (nonatomic, strong) NSArray *schemes;

@end

@implementation LXRouter

+ (instancetype)shareRouter;{
    
    static LXRouter *router = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        router = [[LXRouter alloc]init];
        router.schemes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"LSApplicationQueriesSchemes"];
    });
    
    return router;
}

// - https://LivexuTestVC.push?title=bobo&status=0
- (void)routeMap:(nonnull NSString *)route animated:(BOOL)flag completion:(void (^ __nullable)(void))completion;{
   
    NSString *eRoute = [route stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *routeUrl = [NSURL URLWithString:eRoute];
    
    //如果是网址,直接web
    if ([self expressWeb:routeUrl animated:flag]) return;
    
    //如果是白名单scheme,直接跳转
    if ([self expressSchemes:routeUrl]) return ;
    
    if (self.routeDelegate && [self.routeDelegate respondsToSelector:@selector(routeProject)]) {
        
        NSString *cerScheme = [self.routeDelegate routeProject];
        
        if (![routeUrl.scheme isEqualToString:cerScheme]) {//验证scheme 是否一致，不一致即抛弃
            
            NSLog(@"未受认证的scheme,被拒绝");
            return;
        }
    }
    
    //.host
    NSString *objectAction = routeUrl.host; //= toVC.push
    
    NSString *jumpType;//跳转方式
    if (![objectAction containsString:@".push"] && ![objectAction containsString:@".present"]) {
        
        NSLog(@"未指定确切的跳转方式,被拒绝");
        return;
    }else{
        jumpType = [objectAction substringFromIndex:[objectAction rangeOfString:@"."].location +1];
        
    }
    
    NSString *classString = [objectAction substringToIndex:[objectAction rangeOfString:@"."].location];
    
    //此处添加映射表 - 确定跳转目录
    if (self.routeDelegate && [self.routeDelegate respondsToSelector:@selector(lxRouteCustomPropertyMapper)] && classString) {
        
        NSDictionary *customMapper = [self.routeDelegate lxRouteCustomPropertyMapper];
        
        NSString *class_stand = [customMapper objectForKey:classString];
        
        classString = class_stand ? class_stand :classString;
    }
    
    Class CurrentClass = NSClassFromString(classString);
    
    if (!CurrentClass && ([jumpType isEqualToString:@"present"] || [jumpType isEqualToString:@"push"])) {
        
        NSLog(@"%@ Have No",classString);
        return;
    }
    //确定创建
    UIViewController *currentViewController = [[CurrentClass alloc] init];
    
    //.query
    NSString *queryParameter = routeUrl.query;
    
    NSArray *queryList = [queryParameter componentsSeparatedByString:@"&"];
    
    NSArray *names = [self getAllIvarList:classString];
    
    for (NSString *subQuery in queryList) {
        
        if (![subQuery containsString:@"="]) {
            continue;
        }
        
        NSString *paramString = [subQuery substringToIndex:[subQuery rangeOfString:@"="].location];
        
        if (![names containsObject:paramString]) {
            continue;
        }
        
        NSString *paramResult = [subQuery substringFromIndex:[subQuery rangeOfString:@"="].location +1];
        paramResult = [paramResult stringByRemovingPercentEncoding];
        
        [currentViewController setValue:paramResult forKey:paramString];
    }
    
    if (classString && currentViewController) {
        
        currentViewController.lx_stores = [[LXRouter shareRouter].lxStoreList objectForKey:classString];
        
        [[LXRouter shareRouter].lxStoreList removeObjectForKey:classString];
    }

    if ([jumpType isEqualToString:@"present"]) {
        
        [[self topViewController] presentViewController:currentViewController animated:flag completion:completion];
        
    } else if ([jumpType isEqualToString:@"push"]) {
        
        [[self topViewController].navigationController pushViewController:currentViewController animated:flag];
        if (completion) {
            completion();
        }
    }
    
}

//获取所有的成员变量名称
- (NSArray *)getAllIvarList:(NSString *)className {
    unsigned int methodCount = 0;
    Ivar * ivars = class_copyIvarList([NSClassFromString(className) class], &methodCount);
    NSMutableArray *names = [NSMutableArray array];
    for (unsigned int i = 0; i < methodCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
//        const char * type = ivar_getTypeEncoding(ivar);
//        NSLog(@"Person拥有的成员变量的类型为%s，名字为 %s ",type, name);
        [names addObject:[[NSString stringWithFormat:@"%s",name] stringByReplacingOccurrencesOfString:@"_" withString:@""]];
    }
    free(ivars);
    
    return names;
}

//获取最上层控制器
- (UIViewController *)topViewController;{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

- (BOOL)expressWeb:(NSURL *)url animated: (BOOL)flag {
    
    NSString *webUrlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSPredicate *webUrlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",webUrlRegex];
    BOOL isWeb = [webUrlPredicate evaluateWithObject:url.description];
    
    if (!isWeb) return NO;//不是web直接返回
    
    // 确定跳转web
    NSString *classString;
    if (self.routeDelegate && [self.routeDelegate respondsToSelector:@selector(lxRouteCustomPropertyMapper)]) {
        
        NSDictionary *customMapper = [self.routeDelegate lxRouteCustomPropertyMapper];
        
        classString = [customMapper objectForKey:@"http"];
        
        if (!classString) {
            
            classString = [customMapper objectForKey:@"https"];
        }
        if (!classString) {
            
            NSLog(@"Mapper have no http(s)");
            return NO;
        }
    }
    
    Class CurrentClass = NSClassFromString(classString);
    
    UIViewController *currentViewController = [[CurrentClass alloc] init];
    
    if (currentViewController) {
        
        [currentViewController setValue:url.description forKey:@"urlString"];
    }
    
    [[self topViewController].navigationController pushViewController:currentViewController animated:flag];
    
    return YES;
}

- (BOOL)expressSchemes:(NSURL *)url {
    
    //route验证跳转必须加入白名单 - 不想通过白名单请调用openScheme
    if (![_schemes containsObject: url.scheme] && ![url.absoluteString containsString:kSystemUrlContainString]) {
        
        return NO;
    }
    [self openScheme:url];
    
    return YES;
}

- (void)routeStore:(NSString *)vcString stores:(id _Nullable (^__nullable)(id _Nullable backInfo))stores{
    
    NSString *classString = vcString;
    //此处添加映射表 - 确定跳转目录
    if (self.routeDelegate && [self.routeDelegate respondsToSelector:@selector(lxRouteCustomPropertyMapper)]) {
        
        NSDictionary *customMapper = [self.routeDelegate lxRouteCustomPropertyMapper];
        
        NSString *class_stand = [customMapper objectForKey:classString];
        
        classString = class_stand ? class_stand :classString;
    }
    
    Class CurrentClass = NSClassFromString(classString);
    
    if (!CurrentClass) {
        
        NSLog(@"%@ Have No",classString);
        return;
    }
    
    [[LXRouter shareRouter].lxStoreList setValue:stores forKey:classString];
}

- (NSMutableDictionary *)lxStoreList {
    if (!_lxStoreList) {
        
        _lxStoreList = [NSMutableDictionary dictionary];
    }
    return _lxStoreList;
}

/**
 打开链接
 
 @param schemeURL 链接地址
 */
- (void)openScheme:(NSURL *_Nonnull)schemeURL {
    UIApplication *application = [UIApplication sharedApplication];
    
    if (@available(iOS 10.0, *)) {
        [application openURL:schemeURL options:@{}
           completionHandler:^(BOOL success) {
               
           }];
    } else {
        // Fallback on earlier versions
        [application openURL:schemeURL];
    }
}

/**
 收到链接
 
 @param schemeURL 链接地址
 */
- (void)receiveScheme:(NSURL *_Nonnull)schemeURL;{
    
//    //获取到配置的所有的链接
//    NSArray *arrayScheme = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
//    
//    NSMutableArray *collectSchemes = [NSMutableArray array];
//    
//    for (NSDictionary *dicScheme in arrayScheme) {
//        
//        NSArray *oneSchemes = dicScheme[@"CFBundleURLSchemes"];
//        
//        [collectSchemes addObjectsFromArray:oneSchemes];
//    }
//    
//    BOOL isContainScheme = [collectSchemes containsObject:schemeURL.scheme];
    
    if (self.routeDelegate && [self.routeDelegate respondsToSelector:@selector(routeProject)]) {

        NSString *cerScheme = [self.routeDelegate routeProject];

        NSString *newUrl = [schemeURL.description stringByReplacingOccurrencesOfString:schemeURL.scheme withString:cerScheme];
        
        [self routeMap:newUrl animated:YES completion:nil];
    }else{
        
        [self routeMap:schemeURL.description animated:YES completion:nil];
    }
}

@end

@implementation UIViewController (RouteStoreSupport)

- (LXStores)lx_stores{
    
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLx_stores:(LXStores)lx_stores{
    
    [self willChangeValueForKey:@"lx_stores"];
    objc_setAssociatedObject(self, @selector(lx_stores), lx_stores, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"lx_stores"];
}

@end


