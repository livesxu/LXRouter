//
//  Test1ViewController.m
//  RouterExample
//
//  Created by livesxu on 2018/8/15.
//  Copyright © 2018年 Livesxu. All rights reserved.
//

#import "Test1ViewController.h"

#import "LXRouter.h"

@interface Test1ViewController ()

@end

@implementation Test1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    
    if (self.lx_stores) {
        
        UIButton *passInfo = [[UIButton alloc]initWithFrame:CGRectMake(20, 150, 150, 30)];
        [passInfo setTitle:self.lx_stores(nil) forState:UIControlStateNormal];
        
        [passInfo addTarget:self action:@selector(someBackTest) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:passInfo];
    }
    
    UIButton *back = [[UIButton alloc]initWithFrame:CGRectMake(20, 88, 60, 60)];
    [back setTitle:@"back" forState:UIControlStateNormal];
    [self.view addSubview:back];
    
    [back addTarget:self action:@selector(backTest) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, 200, 20)];
    label.text = [NSString stringWithFormat:@"%@%@",self.name,self.type];
    [self.view addSubview:label];
}

- (void)someBackTest {
    
    if (self.lx_stores) {
        
        self.lx_stores(@"some info call back");
    }
}

- (void)backTest {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
