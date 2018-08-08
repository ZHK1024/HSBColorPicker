//
//  ViewController.m
//  HSBColor
//
//  Created by ZHK on 2018/8/8.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#import "ViewController.h"
#import "HSBRender.h"

@interface ViewController ()

@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) HSBRender    *render;
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.metalLayer = [[CAMetalLayer alloc] init];
    _metalLayer.frame = CGRectMake(30, 80, 315, 315);
    [self.view.layer addSublayer:_metalLayer];
    self.render = [[HSBRender alloc] init];
    _render.layer = _metalLayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -

/**
 计算取色

 @param point 色盘上颜色的点
 @return 颜色 HSB
 */
- (UIColor *)pickColorWithPoint:(CGPoint)point {
    CGFloat h = _slider.value;
    CGFloat s = point.x / CGRectGetWidth(_metalLayer.frame);
    CGFloat b = 1 - point.y / CGRectGetHeight(_metalLayer.frame);
    return [UIColor colorWithHue:h / 360 saturation:s brightness:b alpha:1];
}

#pragma mark - Actions

- (IBAction)tapAction:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.view];
    point = [self.view.layer convertPoint:point toLayer:_metalLayer];
    if ([_metalLayer containsPoint:point]) {
        _resultView.backgroundColor = [self pickColorWithPoint:point];
    }
}

- (IBAction)sliderAction:(UISlider *)sender {
    // 此处 slider 范围为 0 - 359, 值达到360 , 计算就出问题了, 色盘上变为多色渐变
    _render.hues = sender.value;
}

@end
