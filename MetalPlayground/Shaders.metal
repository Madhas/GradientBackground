//
//  Shaders.metal
//  MetalPlayground
//
//  Created by Андрей Овсянников on 17.01.2021.
//

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    float4 position;
    float4 displacementColor;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 displacementColor;
};

struct FragmentOut {
    float4 color [[ color(0) ]];
    float4 displacementColor [[ color(1) ]];
};

vertex VertexOut vertex_shader(device const VertexIn *vertices [[ buffer(0) ]],
                               uint vid [[ vertex_id ]]) {
    VertexOut out;
    out.position = vertices[vid].position;
    out.displacementColor = vertices[vid].displacementColor;
    return out;
}

fragment FragmentOut fragment_shader(const VertexOut in [[ stage_in ]],
                                     constant const float4 *colors [[ buffer(0) ]],
                                     constant const float2 *controlPoints [[ buffer(1) ]]) {
    FragmentOut out;
    out.displacementColor = in.displacementColor;
    
    float2 position = float2(in.position.x, in.position.y);
    float dists[4];
    float total = 0;
    for (int i = 0; i < 4; ++i) {
        float d = distance(controlPoints[i], position);
        if (d == 0) {
            out.color = colors[i];
            return out;
        }
        
        d = 1 / (d * d);
        dists[i] = d;
        total += d;
    }
    
    float4 color = float4(0, 0, 0, 1);
    for (int i = 0; i < 4; ++i) {
        float ratio = dists[i] / total;
        color += ratio * colors[i];
    }
    
    out.color = color;
    return out;
}

kernel void displaceTexture(texture2d<float, access::read> source [[ texture(0) ]],
                            texture2d<float, access::read> map [[ texture(1) ]],
                            texture2d<float, access::write> dest [[ texture(2) ]],
                            uint2 pos [[ thread_position_in_grid ]]) {
    uint maxWidth = dest.get_width();
    uint maxHeight = dest.get_height();
//    if (pos.x >= maxWidth || pos.y >= maxHeight) {
//        return;
//    }
    pos.x = pos.x >= maxWidth ? pos.x - maxWidth : pos.x;
    pos.y = pos.y >= maxHeight ? pos.y - maxHeight : pos.y;
    
    float amount = 30;
    
    float4 sourceColor = source.read(pos);
    float4 displacementColor = map.read(pos);
    
    float dx = amount * ((displacementColor[0] - 128) / 128);
    float dy = amount * ((displacementColor[1] - 128) / 128);
    
    uint x = pos.x + dx;
    uint y = pos.y + dy;
    uint2 destPos = uint2(clamp(x, uint(0), maxWidth),
                          clamp(y, uint(0), maxHeight));
    
    dest.write(sourceColor, destPos);
    
//    dest.write(float4(0, 1, 0, 1), destPos);
}
