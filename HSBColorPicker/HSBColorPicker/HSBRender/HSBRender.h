//
//  HSBRender.h
//  HSBColor
//
//  Created by ZHK on 2018/8/8.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#import <MetalKit/MetalKit.h>


@interface HSBRender : NSObject

@property (nonatomic, strong) CAMetalLayer *layer;
@property (nonatomic, assign) float         hues;   // 范围 [0, 360)

@end
