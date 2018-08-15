//
//  ViewController.m
//  RouterExample
//
//  Created by livesxu on 2018/8/15.
//  Copyright © 2018年 Livesxu. All rights reserved.
//

#import "ViewController.h"

#import "LXRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *present1 = [[UIButton alloc]initWithFrame:CGRectMake(20, 88, 90, 30)];
    [present1 setTitle:@"present1" forState:UIControlStateNormal];
    present1.backgroundColor = [UIColor blueColor];
    [self.view addSubview:present1];
    
    
    [present1 addTarget:self action:@selector(present1Test) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *present = [[UIButton alloc]initWithFrame:CGRectMake(220, 88, 90, 30)];
    [present setTitle:@"present2" forState:UIControlStateNormal];
    present.backgroundColor = [UIColor blueColor];
    [self.view addSubview:present];
    
    [present addTarget:self action:@selector(presentTest) forControlEvents:UIControlEventTouchUpInside];
}

//传值、回调演示
- (void)present1Test {
    
    [[LXRouter shareRouter] routeStore:@"test1" stores:^id _Nullable(id  _Nullable backInfo) {
        
        NSLog(@"%@",backInfo);
        
        return @"pass some info";
    }];
    LXRouteMap(@"ProjectName://test1.present?name=波波&type=route演示");
}

//非传值演示 - 无映射
- (void)presentTest {
    
    LXRouteMap(@"ProjectName://Test1ViewController.present");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
