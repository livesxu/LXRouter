//
//  LXRouter.h
//  TestRouterLX
//
//  Created by Livespro on 2017/7/10.
//  Copyright © 2017年 Livespro. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void(^LXRouterTaskBlock)(void);

@protocol LXRouteDelegate <NSObject>

@required

@optional

- (NSString *_Nonnull)routeProject;

- (NSDictionary *_Nonnull)lxRouteCustomPropertyMapper;

@end

void LXRouteMap(NSString *route);

@interface LXRouter : NSObject

@property (nonatomic, assign) id <LXRouteDelegate> _Nullable routeDelegate;


/**
 route 单例

 @return route单例
 */
+ (instancetype _Nonnull )shareRouter;

/**
 Map 跳转

 @param route 跳转链接
 @param flag ? animating
 @param completion ?completion action
 */
- (void)routeMap:(nonnull NSString *)route animated:(BOOL)flag completion:(void (^ __nullable)(void))completion;

/**
 store 保存执行回调(绑定传递

 @param vcString 传递到控制器
 @param stores 保存的内容
 */
- (void)routeStore:(NSString *_Nonnull)vcString stores:(id _Nullable (^__nullable)(id _Nullable backInfo))stores;

/**
 打开链接
 
 @param schemeURL 链接地址
 */
- (void)openScheme:(NSURL *_Nonnull)schemeURL;

/**
 收到链接

 @param schemeURL 链接地址
 */
- (void)receiveScheme:(NSURL *_Nonnull)schemeURL;


/**
 获取最上层控制器

 @return vc
 */
- (UIViewController *_Nonnull)topViewController;

/**
 非链接式注册响应操作 - 任务

 @param routeKey 任务key
 @param routeHandle 任务执行
 */
- (void)routeJoinTaskWithKey:(NSString *_Nonnull)routeKey RouteHandle:(LXRouterTaskBlock)routeHandle;

/**
 非链接式移除操作

 @param routeKey 任务key
 */
- (void)routeRemoveTaskWithKey:(NSString *_Nonnull)routeKey;

@end

#import <UIKit/UIKit.h>

typedef id _Nullable (^LXStores)(id _Nullable );

@interface UIViewController (RouteStoreSupport)

@property (nonatomic,   copy) LXStores _Nullable lx_stores;

@end










