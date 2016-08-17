//
//  ViewController.m
//  line
//
//  Created by Xmart on 16/8/17.
//  Copyright © 2016年 Paul.Chen. All rights reserved.
//

#import "ViewController.h"
#import "LineView.h"

@interface ViewController ()
@property (strong, nonatomic) LineView *testView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _testView = [[LineView alloc]initWithFrame:CGRectMake(0,
                                                          0,
                                                          self.view.bounds.size.width,
                                                          self.view.bounds.size.height)];
    [self.view addSubview:_testView];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [_testView removeFromSuperview];
//    _testView = [[TxstView alloc]initWithFrame:CGRectMake(0,
//                                                          0,
//                                                          self.view.bounds.size.width,
//                                                          self.view.bounds.size.height)];
//    [self.view addSubview:_testView];
    [_testView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
