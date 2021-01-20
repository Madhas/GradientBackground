//
//  Shaders.metal
//  MetalPlayground
//
//  Created by Андрей Овсянников on 17.01.2021.
//

#include <metal_stdlib>

using namespace metal;

struct VertexOut {
    float4 position [[ position ]];
};

vertex VertexOut vertex_shader(device const float4 *vertices [[ buffer(0) ]],
                               uint vid [[ vertex_id ]]) {
    VertexOut out;
    out.position = vertices[vid];
    return out;
}

fragment float4 fragment_shader(const VertexOut in [[ stage_in ]],
                                constant const float4 *colors [[ buffer(0) ]],
                                constant const float2 *controlPoints [[ buffer(1) ]]) {
    
    float2 position = float2(in.position.x, in.position.y);
    
    float dists[4];
    float total = 0;
    for (int i = 0; i < 4; ++i) {
        float d = distance(controlPoints[i], position);
        if (d == 0) {
            return colors[i];
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
    
    return color;
}

kernel void displaceTexture(texture2d<float, access::read> source [[ texture(0) ]],
                            texture2d<float, access::write> dest [[ texture(1) ]],
                            uint2 pos [[ thread_position_in_grid ]]) {
    uint maxWidth = dest.get_width();
    uint maxHeight = dest.get_height();

    float amount = 20;
    if (pos.x >= maxWidth || pos.y >= maxHeight) {
        return;
    }
    
    uint2 destPos;
    float4 color = source.read(pos);
    
    if (pos.y < maxHeight / 2) {
        dest.write(float4(1, 0, 0, 1), pos);
        return;
    } else {
        if (pos.y < -0.5 * maxHeight / maxWidth * pos.x + maxHeight) {
            destPos = uint2(pos.x - amount, pos.y + amount);
        } else {
            destPos = uint2(pos.x - amount, pos.y + amount);
        }
    }
    
    dest.write(color, destPos);
}
