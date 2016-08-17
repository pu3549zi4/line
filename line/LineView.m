//
//
//  Created by Amor on 16/3/25.
//  Copyright © 2016年 Amor. All rights reserved.
//

#import "LineView.h"
#define g 9.8
//#define h_man 1.6           //出手高度
#define H_bar 1.73          //靶心地面高度
#define D_bar 0.457         //靶直径
#define L_long 2.43         //人到靶距离

#define max_man 2.1         //最大高度
#define line_w 1.0          //线宽

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface LineView()
@property (nonatomic, assign) float maxS;
@property (nonatomic, assign) float maxH;
@property (nonatomic, assign) float maxT;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float coner;


@end
@implementation LineView
{
    float T;  //总时间
    float H;  //最大高度
    float S;  //最大射程
    
    NSMutableArray *array;
    UIBezierPath* aPath;
    UIBezierPath* bPath;
    NSTimer *atimer;
    
    NSMutableArray *sec_array;
    UIBezierPath* sec_aPath;
    UIBezierPath* sec_bPath;
    NSTimer *sec_atimer;
    
    NSMutableArray *third_array;
    UIBezierPath *third_aPath;
    UIBezierPath *third_bPath;
    NSTimer *third_atimer;

    
    NSUserDefaults *userDefault;
}

- (void)drawRect:(CGRect)rect {
    
    UIView *view = [[UIView alloc]initWithFrame:rect];
    view.backgroundColor = [UIColor grayColor];
    [self addSubview:view];

    
    _maxS = 2.37;
    _maxH = _maxT = 0;
    _coner = 60;
    _speed = 4.0f;
    userDefault = [NSUserDefaults standardUserDefaults];

    CGRect curr_rect;
    if (rect.size.width/rect.size.height>L_long/(max_man-0.5)) {
        curr_rect = CGRectMake((rect.size.width-rect.size.height*L_long/(max_man-0.5))/2, 0, rect.size.height*L_long/(max_man-0.5), rect.size.height);
    }else {
        curr_rect = CGRectMake(0, (rect.size.height-rect.size.width/(L_long/(max_man-0.5)))/2, rect.size.width, rect.size.width/(L_long/(max_man-0.5)));
    }
    
    //内部填充
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:curr_rect];
    imageView.contentMode = UIViewContentModeScaleToFill;
//    imageView.image = [UIImage imageNamed:@"backgroundImageName"];
    imageView.backgroundColor = [UIColor magentaColor];
    [self addSubview:imageView];
    
    [self drawFirstLineWithSpeed:1 andVersticalAngle:30 andRect:curr_rect andUserHeight:170/100.0];
    [self drawFirstLineWithSpeed:5 andVersticalAngle:30 andRect:curr_rect andUserHeight:170/100.0];
    [self drawFirstLineWithSpeed:10 andVersticalAngle:30 andRect:curr_rect andUserHeight:170/100.0];
    [self drawFirstLineWithSpeed:1 andVersticalAngle:60 andRect:curr_rect andUserHeight:170/100.0];
    [self drawFirstLineWithSpeed:5 andVersticalAngle:60 andRect:curr_rect andUserHeight:170/100.0];
    [self drawFirstLineWithSpeed:10 andVersticalAngle:60 andRect:curr_rect andUserHeight:170/100.0];
    
}

- (void)drawFirstLineWithSpeed:(float)speed andVersticalAngle:(float)versticalAngle andRect:(CGRect)rect andUserHeight:(float)userHeight {
    float angle = fabsf(versticalAngle)/180*M_PI;
    T = L_long/(speed*cos(angle));
    array = [NSMutableArray array];
    NSMutableArray *firstArr = [NSMutableArray array];
    
    for (double i = 0; i < 1000; i ++) {
        
        float t = T/1000*i;//1;
        
        double x = speed *cos(angle)*t;
        double y;
        if (versticalAngle>0) {
            y = -speed*sin(angle)*t + g*t*t/2;
        }else {
            y = speed*sin(angle)*t + g*t*t/2;
        }
        
        if (y<userHeight-max_man) {
            if (firstArr.count>0) {
                [array addObject:firstArr.mutableCopy];
                [firstArr removeAllObjects];
            }
        }else if (y>userHeight-0.5 || x>L_long) {
            [array addObject:firstArr.mutableCopy];
            [firstArr removeAllObjects];
            break;
        }else {
            [firstArr addObject:@[[NSString stringWithFormat:@"%f",x],[NSString stringWithFormat:@"%f",y]]];
        }
    }
//    NSLog(@"%@",array);
    if (array.count<1) {
        if (speed>0) {
            [array addObject:firstArr.mutableCopy];
            [firstArr removeAllObjects];
        }
    }
    if (array.count>0) {
        NSArray *a_arr = [NSArray arrayWithArray:array[0]];
        
        // 第一、 UIBezierPath 绘制线段
        
        UIColor *color = [UIColor clearColor];
        [color set];  //设置线条颜色
        aPath = [UIBezierPath bezierPath];
        aPath.lineWidth = 1.5;
        aPath.lineCapStyle = kCGLineCapRound;  //线条拐角
        aPath.lineJoinStyle = kCGLineCapRound;  //终点处理
        
        float start_w_x = rect.origin.x;
        float start_h_y = rect.origin.y + (max_man-userHeight)*rect.size.height/(max_man-0.5); //屏幕出手点
        
        [aPath moveToPoint:CGPointMake(start_w_x, start_h_y)];//起点
        for (int i=0; i<a_arr.count; i++) {
            if (i>0) {
                float p_x = start_w_x + [a_arr[i][0] floatValue]*rect.size.width/L_long;
                float p_y = start_h_y + [a_arr[i][1] floatValue]*rect.size.height/(max_man-0.5);
                CGPoint p = CGPointMake(p_x, p_y);
//                NSLog(@"%f--%f",p.x,p.y);
                [aPath addLineToPoint:p];
            }
        }
        [aPath stroke];
        
        // 第二、 UIBezierPath 和 CAShapeLayer 关联
        
        CAShapeLayer *lineLayer2 = [CAShapeLayer layer];
        lineLayer2. frame = CGRectZero;
        lineLayer2. fillColor = [UIColor clearColor]. CGColor ;
        lineLayer2. path = aPath. CGPath ;
        lineLayer2. strokeColor = [UIColor greenColor]. CGColor ;
        lineLayer2. lineWidth = 1.5;
        
        //第三，动画
        
        CABasicAnimation *ani = [ CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
        ani. fromValue = @0;
        ani. toValue = @1;
        ani. duration = 1.00/1000*a_arr.count;//0.6 ;
        [lineLayer2 addAnimation :ani forKey : NSStringFromSelector ( @selector (strokeEnd))];
        [self.layer addSublayer :lineLayer2];
        
        if (array.count == 2) {
            NSArray *b_arr = [NSArray arrayWithArray:array[1]];
            // 第一、 UIBezierPath 绘制线段
            
            UIColor *b_color = [UIColor clearColor];
            [b_color set];  //设置线条颜色
            bPath = [UIBezierPath bezierPath];
            bPath.lineWidth = 1.5;
            bPath.lineCapStyle = kCGLineCapRound;  //线条拐角
            bPath.lineJoinStyle = kCGLineCapRound;  //终点处理
            
            for (int i=0; i<b_arr.count; i++) {
                float p_x = start_w_x + [b_arr[i][0] floatValue]*rect.size.width/L_long;
                float p_y = start_h_y + [b_arr[i][1] floatValue]*rect.size.height/(max_man-0.5);
                CGPoint p = CGPointMake(p_x, p_y);
//                NSLog(@"%f--%f",p.x,p.y);
                if (i>0) {
                    [bPath addLineToPoint:p];
                }else {
                    [bPath moveToPoint:p];//起点
                }
            }
            [bPath stroke];
            
            atimer = [NSTimer scheduledTimerWithTimeInterval:1.00/1000*(1000-a_arr.count-b_arr.count) target:self selector:@selector(delayFirstSecondLine) userInfo:nil repeats:NO];
            
        }
    }
}

- (void)delayFirstSecondLine {
    NSArray *b_arr = [NSArray arrayWithArray:array[1]];
    [atimer invalidate];
    // 第二、 UIBezierPath 和 CAShapeLayer 关联
    
    CAShapeLayer *blineLayer2 = [CAShapeLayer layer];
    blineLayer2. frame = CGRectZero;
    blineLayer2. fillColor = [UIColor clearColor]. CGColor ;
    blineLayer2. path = bPath. CGPath ;
    blineLayer2. strokeColor = [UIColor greenColor]. CGColor ;
    blineLayer2. lineWidth = 1.5;
    
    //第三，动画
    
    CABasicAnimation *bani = [ CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
    bani. fromValue = @0;
    bani. toValue = @1;
    bani. duration = 1.00/1000*b_arr.count;//0.6 ;
    [blineLayer2 addAnimation :bani forKey : NSStringFromSelector ( @selector (strokeEnd))];
    [self.layer addSublayer :blineLayer2];
}

- (void)drawSecondLineWithSpeed:(float)speed andVersticalAngle:(float)versticalAngle andRect:(CGRect)rect  andUserHeight:(float)userHeight {
    float angle = fabsf(versticalAngle)/180*M_PI;
    T = L_long/(speed*cos(angle));
    sec_array = [NSMutableArray array];
    NSMutableArray *firstArr = [NSMutableArray array];
    
    for (double i = 0; i < 1000; i ++) {
        
        float t = T/1000*i;//1;
        
        double x = speed *cos(angle)*t;
        double y;
        if (versticalAngle>0) {
            y = -speed*sin(angle)*t + g*t*t/2;
        }else {
            y = speed*sin(angle)*t + g*t*t/2;
        }
        
        if (y<userHeight-max_man) {
            if (firstArr.count>0) {
                [sec_array addObject:firstArr.mutableCopy];
                [firstArr removeAllObjects];
            }
        }else if (y>userHeight-0.5 || x>L_long) {
            [sec_array addObject:firstArr.mutableCopy];
            [firstArr removeAllObjects];
            break;
        }else {
            [firstArr addObject:@[[NSString stringWithFormat:@"%f",x],[NSString stringWithFormat:@"%f",y]]];
        }
    }
//    NSLog(@"%@",sec_array);
    if (sec_array.count<1) {
        if (speed>0) {
            [sec_array addObject:firstArr.mutableCopy];
            [firstArr removeAllObjects];
        }
    }
    if (sec_array.count>0) {
        NSArray *a_arr = [NSArray arrayWithArray:sec_array[0]];
        
        // 第一、 UIBezierPath 绘制线段
        
        UIColor *color = [UIColor clearColor];
        [color set];  //设置线条颜色
        sec_aPath = [UIBezierPath bezierPath];
        sec_aPath.lineWidth = 1.5;
        sec_aPath.lineCapStyle = kCGLineCapRound;  //线条拐角
        sec_aPath.lineJoinStyle = kCGLineCapRound;  //终点处理
        
        float start_w_x = rect.origin.x;
        float start_h_y = rect.origin.y + (max_man-userHeight)*rect.size.height/(max_man-0.5); //屏幕出手点
        
        [sec_aPath moveToPoint:CGPointMake(start_w_x, start_h_y)];//起点
        for (int i=0; i<a_arr.count; i++) {
            if (i>0) {
                float p_x = start_w_x + [a_arr[i][0] floatValue]*rect.size.width/L_long;
                float p_y = start_h_y + [a_arr[i][1] floatValue]*rect.size.height/(max_man-0.5);
                CGPoint p = CGPointMake(p_x, p_y);
//                NSLog(@"%f--%f",p.x,p.y);
                [sec_aPath addLineToPoint:p];
            }
        }
        [sec_aPath stroke];
        
        // 第二、 UIBezierPath 和 CAShapeLayer 关联
        
        CAShapeLayer *lineLayer2 = [CAShapeLayer layer];
        lineLayer2. frame = CGRectZero;
        lineLayer2. fillColor = [UIColor clearColor]. CGColor ;
        lineLayer2. path = sec_aPath. CGPath ;
        lineLayer2. strokeColor = [UIColor yellowColor]. CGColor ;
        lineLayer2. lineWidth = 1.5;
        
        //第三，动画
        
        CABasicAnimation *ani = [ CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
        ani. fromValue = @0;
        ani. toValue = @1;
        ani. duration = 1.00/1000*a_arr.count;//0.6 ;
        [lineLayer2 addAnimation :ani forKey : NSStringFromSelector ( @selector (strokeEnd))];
        [self.layer addSublayer :lineLayer2];
        
        if (sec_array.count == 2) {
            NSArray *b_arr = [NSArray arrayWithArray:sec_array[1]];
            // 第一、 UIBezierPath 绘制线段
            
            UIColor *b_color = [UIColor clearColor];
            [b_color set];  //设置线条颜色
            sec_bPath = [UIBezierPath bezierPath];
            sec_bPath.lineWidth = 1.5;
            sec_bPath.lineCapStyle = kCGLineCapRound;  //线条拐角
            sec_bPath.lineJoinStyle = kCGLineCapRound;  //终点处理
            
            for (int i=0; i<b_arr.count; i++) {
                float p_x = start_w_x + [b_arr[i][0] floatValue]*rect.size.width/L_long;
                float p_y = start_h_y + [b_arr[i][1] floatValue]*rect.size.height/(max_man-0.5);
                CGPoint p = CGPointMake(p_x, p_y);
//                NSLog(@"%f--%f",p.x,p.y);
                if (i>0) {
                    [sec_bPath addLineToPoint:p];
                }else {
                    [sec_bPath moveToPoint:p];//起点
                }
            }
            [sec_bPath stroke];
            
            sec_atimer = [NSTimer scheduledTimerWithTimeInterval:1.00/1000*(1000-a_arr.count-b_arr.count) target:self selector:@selector(delaySecondSecondLine) userInfo:nil repeats:NO];
            
        }
    }
}

- (void)delaySecondSecondLine {
    NSArray *b_arr = [NSArray arrayWithArray:sec_array[1]];
    [sec_atimer invalidate];
    // 第二、 UIBezierPath 和 CAShapeLayer 关联
    
    CAShapeLayer *blineLayer2 = [CAShapeLayer layer];
    blineLayer2. frame = CGRectZero;
    blineLayer2. fillColor = [UIColor clearColor]. CGColor ;
    blineLayer2. path = sec_bPath. CGPath ;
    blineLayer2. strokeColor = [UIColor yellowColor]. CGColor ;
    blineLayer2. lineWidth = 1.5;
    
    //第三，动画
    
    CABasicAnimation *bani = [ CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
    bani. fromValue = @0;
    bani. toValue = @1;
    bani. duration = 1.00/1000*b_arr.count;//0.6 ;
    [blineLayer2 addAnimation :bani forKey : NSStringFromSelector ( @selector (strokeEnd))];
    [self.layer addSublayer :blineLayer2];
}

- (void)drawThirdLineWithSpeed:(float)speed andVersticalAngle:(float)versticalAngle andRect:(CGRect)rect  andUserHeight:(float)userHeight {
    float angle = fabsf(versticalAngle)/180*M_PI;
    T = L_long/(speed*cos(angle));
    third_array = [NSMutableArray array];
    NSMutableArray *firstArr = [NSMutableArray array];
    
    for (double i = 0; i < 1000; i ++) {
        
        float t = T/1000*i;//1;
        
        double x = speed *cos(angle)*t;
        double y;
        if (versticalAngle>0) {
            y = -speed*sin(angle)*t + g*t*t/2;
        }else {
            y = speed*sin(angle)*t + g*t*t/2;
        }
        
        if (y<userHeight-max_man) {
            if (firstArr.count>0) {
                [third_array addObject:firstArr.mutableCopy];
                [firstArr removeAllObjects];
            }
        }else if (y>userHeight-0.5 || x>L_long) {
            [third_array addObject:firstArr.mutableCopy];
            [firstArr removeAllObjects];
            break;
        }else {
            [firstArr addObject:@[[NSString stringWithFormat:@"%f",x],[NSString stringWithFormat:@"%f",y]]];
        }
    }
//    NSLog(@"%@",third_array);
    if (third_array.count<1) {
        if (speed>0) {
            [third_array addObject:firstArr.mutableCopy];
            [firstArr removeAllObjects];
        }
    }
    if (third_array.count>0) {
        NSArray *a_arr = [NSArray arrayWithArray:third_array[0]];
        
        // 第一、 UIBezierPath 绘制线段
        
        UIColor *color = [UIColor clearColor];
        [color set];  //设置线条颜色
        third_aPath = [UIBezierPath bezierPath];
        third_aPath.lineWidth = 1.5;
        third_aPath.lineCapStyle = kCGLineCapRound;  //线条拐角
        third_aPath.lineJoinStyle = kCGLineCapRound;  //终点处理
        
        float start_w_x = rect.origin.x;
        float start_h_y = rect.origin.y + (max_man-userHeight)*rect.size.height/(max_man-0.5); //屏幕出手点
        
        [third_aPath moveToPoint:CGPointMake(start_w_x, start_h_y)];//起点
        for (int i=0; i<a_arr.count; i++) {
            if (i>0) {
                float p_x = start_w_x + [a_arr[i][0] floatValue]*rect.size.width/L_long;
                float p_y = start_h_y + [a_arr[i][1] floatValue]*rect.size.height/(max_man-0.5);
                CGPoint p = CGPointMake(p_x, p_y);
//                NSLog(@"%f--%f",p.x,p.y);
                [third_aPath addLineToPoint:p];
            }
        }
        [third_aPath stroke];
        
        // 第二、 UIBezierPath 和 CAShapeLayer 关联
        
        CAShapeLayer *lineLayer2 = [CAShapeLayer layer];
        lineLayer2. frame = CGRectZero;
        lineLayer2. fillColor = [UIColor clearColor]. CGColor ;
        lineLayer2. path = third_aPath. CGPath ;
        lineLayer2. strokeColor = [UIColor blueColor]. CGColor ;
        lineLayer2. lineWidth = 1.5;
        
        //第三，动画
        
        CABasicAnimation *ani = [ CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
        ani. fromValue = @0;
        ani. toValue = @1;
        ani. duration = 1.00/1000*a_arr.count;//0.6 ;
        [lineLayer2 addAnimation :ani forKey : NSStringFromSelector ( @selector (strokeEnd))];
        [self.layer addSublayer :lineLayer2];
        
        if (third_array.count == 2) {
            NSArray *b_arr = [NSArray arrayWithArray:third_array[1]];
            // 第一、 UIBezierPath 绘制线段
            
            UIColor *b_color = [UIColor clearColor];
            [b_color set];  //设置线条颜色
            third_bPath = [UIBezierPath bezierPath];
            third_bPath.lineWidth = 1.5;
            third_bPath.lineCapStyle = kCGLineCapRound;  //线条拐角
            third_bPath.lineJoinStyle = kCGLineCapRound;  //终点处理
            
            for (int i=0; i<b_arr.count; i++) {
                float p_x = start_w_x + [b_arr[i][0] floatValue]*rect.size.width/L_long;
                float p_y = start_h_y + [b_arr[i][1] floatValue]*rect.size.height/(max_man-0.5);
                CGPoint p = CGPointMake(p_x, p_y);
//                NSLog(@"%f--%f",p.x,p.y);
                if (i>0) {
                    [third_bPath addLineToPoint:p];
                }else {
                    [third_bPath moveToPoint:p];//起点
                }
            }
            [third_bPath stroke];
            
            third_atimer = [NSTimer scheduledTimerWithTimeInterval:1.00/1000*(1000-a_arr.count-b_arr.count) target:self selector:@selector(delayThirdSecondLine) userInfo:nil repeats:NO];
            
        }
    }
}

- (void)delayThirdSecondLine {
    NSArray *b_arr = [NSArray arrayWithArray:third_array[1]];
    [third_atimer invalidate];
    // 第二、 UIBezierPath 和 CAShapeLayer 关联
    
    CAShapeLayer *blineLayer2 = [CAShapeLayer layer];
    blineLayer2. frame = CGRectZero;
    blineLayer2. fillColor = [UIColor clearColor]. CGColor ;
    blineLayer2. path = third_bPath. CGPath ;
    blineLayer2. strokeColor = [UIColor blueColor]. CGColor ;
    blineLayer2. lineWidth = 1.5;
    
    //第三，动画
    
    CABasicAnimation *bani = [ CABasicAnimation animationWithKeyPath : NSStringFromSelector ( @selector (strokeEnd))];
    bani. fromValue = @0;
    bani. toValue = @1;
    bani. duration = 1.00/1000*b_arr.count;//0.6 ;
    [blineLayer2 addAnimation :bani forKey : NSStringFromSelector ( @selector (strokeEnd))];
    [self.layer addSublayer :blineLayer2];
}

@end
