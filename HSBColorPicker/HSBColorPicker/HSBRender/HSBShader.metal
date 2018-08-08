//
//  HSBShader.metal
//  HSBColor
//
//  Created by ZHK on 2018/8/8.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ZHKSize {
    float width;
    float height;
};

float3 hsb2rgb(float3 hsb);

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    constant float &hues [[buffer(0)]],
                    constant ZHKSize &size [[buffer(1)]],
                    uint2 gid [[thread_position_in_grid]]) {

    float3 hsb = float3(hues, gid.x / size.width, 1 - gid.y / size.height);
    output.write(float4(hsb2rgb(hsb), 1), gid);
}

// hsb 转换为 rgb
float3 hsb2rgb(float3 hsb) {
    float h = clamp(hsb.r, 0.0, 359.0);
    float s = clamp(hsb.g, 0.0, 1.0);
    float v = clamp(hsb.b, 0.0, 1.0);
    
    float r = 0, g = 0, b = 0;
    int i = (int) (((int)h / 60) % 6);
    float f = (h / 60) - i;
    float p = v * (1 - s);
    float q = v * (1 - f * s);
    float t = v * (1 - (1 - f) * s);
    switch (i) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        case 5:
            r = v;
            g = p;
            b = q;
            break;
        default:
            break;
    }
    return float3(r, g, b);
}
