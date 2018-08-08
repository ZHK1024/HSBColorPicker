//
//  HSBRender.m
//  HSBColor
//
//  Created by ZHK on 2018/8/8.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#import "HSBRender.h"


struct ZHKSize {
    float width;
    float height;
};

@interface HSBRender ()

@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id <MTLComputePipelineState>  cps;
@property (nonatomic, strong) id <MTLBuffer> huesBuffer;
@property (nonatomic, strong) id <MTLBuffer> sizeBuffer;

@end

@implementation HSBRender

#pragma mark -

- (instancetype)init {
    if (self = [super init]) {
        [self config];
    }
    return self;
}

#pragma mark -

- (void)config {
    id <MTLLibrary> library = [self.device newDefaultLibrary];
    id <MTLFunction> kernel = [library newFunctionWithName:@"compute"];
    self.cps = [self.device newComputePipelineStateWithFunction:kernel error:nil];
}

- (void)render {
    id <CAMetalDrawable> drawable = _layer.nextDrawable;
    if (drawable == nil) {
        return;
    }
    id <MTLCommandBuffer> commandBuffer = self.commandQueue.commandBuffer;
    id <MTLComputeCommandEncoder> encoder = commandBuffer.computeCommandEncoder;
    
    [encoder setComputePipelineState:_cps];
    [encoder setTexture:drawable.texture atIndex:0];
    [encoder setBuffer:self.huesBuffer offset:0 atIndex:0];
    [encoder setBuffer:self.sizeBuffer offset:0 atIndex:1];
    
    MTLSize threadGroupCount = MTLSizeMake(8, 8, 1);
    MTLSize threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1);
    
    [encoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupCount];
    [encoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)refreshBuffer {
    struct ZHKSize size = {_layer.drawableSize.width, _layer.drawableSize.height};
    if (CGSizeEqualToSize(_layer.drawableSize, CGSizeZero)) {
        CGFloat scale = [UIScreen mainScreen].scale;
        size.width  = CGRectGetWidth(_layer.frame) * scale;
        size.height = CGRectGetHeight(_layer.frame) * scale;
    }
    // 传入绘制区域的宽高
    memcpy(self.sizeBuffer.contents, &size, sizeof(struct ZHKSize));
    // 传入色相值
    memcpy(self.huesBuffer.contents, &_hues, sizeof(float));
}

#pragma mark - Setter

- (void)setLayer:(CAMetalLayer *)metalLayer {
    if (_layer != metalLayer) {
        _layer = metalLayer;
        _layer.device = self.device;
        _layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        _layer.framebufferOnly = NO;
        _layer.contentsScale = [UIScreen mainScreen].scale;
        // 遇到个 右侧, 底部有级像素未绘制, 呈现黑色
        // 简单天下坑, 暂时不耽误用, 只是显示层的误差(1%的误差)
        _layer.contentsRect = CGRectMake(0, 0, 0.99, 0.99);
        [self refreshBuffer];
        [self render];
    }
}

- (void)setHues:(float)hues {
    if (_hues != hues) {
        _hues = hues;
        [self refreshBuffer];
        [self render];
    }
}

#pragma mark - Getter

- (id<MTLDevice>)device {
    if (_device == nil) {
        self.device = MTLCreateSystemDefaultDevice();
    }
    return _device;
}

- (id<MTLCommandQueue>)commandQueue {
    if (_commandQueue == nil) {
        self.commandQueue = [self.device newCommandQueue];
    }
    return _commandQueue;
}

- (id<MTLBuffer>)huesBuffer {
    if (_huesBuffer == nil) {
        self.huesBuffer = [self.device newBufferWithLength:sizeof(float) options:MTLResourceStorageModeShared];
    }
    return _huesBuffer;
}

- (id<MTLBuffer>)sizeBuffer {
    if (_sizeBuffer == nil) {
        self.sizeBuffer = [self.device newBufferWithLength:sizeof(struct ZHKSize) options:MTLResourceStorageModeShared];
    }
    return _sizeBuffer;
}

@end
