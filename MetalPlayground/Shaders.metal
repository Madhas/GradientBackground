//
//  Shaders.metal
//  MetalPlayground
//
//  Created by Андрей Овсянников on 17.01.2021.
//

#include <metal_stdlib>

using namespace metal;

float triangle_area(float2, float2, float2);

struct VertexIn {
    float4 position;
};

struct VertexOut {
    float4 position [[ position ]];
};


vertex VertexOut vertex_shader(device const VertexIn *vertices [[ buffer(0) ]],
                               uint vid [[ vertex_id ]]) {
    VertexOut out;
    out.position = vertices[vid].position;
    return out;
}

fragment float4 fragment_shader(const VertexOut in [[ stage_in ]],
                                constant const float4 *colors [[ buffer(0) ]],
                                constant const float2 *controlPoints [[ buffer(1) ]]) {
//    float2 Q = controlPoints[0] - controlPoints[2];
//    float2 R = controlPoints[1] - controlPoints[0];
//    float2 S = R + controlPoints[2] - controlPoints[3];
//    float2 T = controlPoints[0] - float2(in.position.x / 375, in.position.y / 812);
//
//    float u;
//    float t;
//
//    if (Q.x == 0 && S.x == 0) {
//        u = -T.x / R.x;
//        t = (T.y + u * R.y) / (Q.y + u * S.y);
//    } else if (Q.y == 0 && S.y == 0) {
//        u = -T.y / R.y;
//        t = (T.x + u * R.x) / (Q.x + u * S.x);
//    } else {
//        float A = S.x * R.y - R.x * S.y;
//        float B = S.x * T.y - T.x * S.y + Q.x * R.y - R.x * Q.y;
//        float C = Q.x * T.y - T.x * Q.y;
//        if (abs(A) < FLT_EPSILON) {
//            u = -C / B;
//        } else {
//            u = (-B + sqrt(pow(B, 2) -4 * A * C)) / (2 * A);
//        }
//        t = (T.y + u * R.y) / (Q.y + u * S.y);
//    }
//
//    u = smoothstep(0, 1, clamp(u, 0.0, 1.0));
//    t = smoothstep(0, 1, clamp(t, 0.0, 1.0));
//
//    float4 color1 = mix(colors[0], colors[1], u);
//    float4 color2 = mix(colors[2], colors[3], u);
//
//    return mix(color1, color2, t);
    
    float2 normalizedPosition = float2(in.position.x / 375, in.position.y / 812);
//    float3 barycentricCoords;
    
    if (normalizedPosition.y <= controlPoints[0].y) {
        return mix(colors[0], colors[1], distance(normalizedPosition, controlPoints[0]));
    } else if (normalizedPosition.y >= controlPoints[2].y) {
        return mix(colors[2], colors[3], distance(normalizedPosition, controlPoints[2]));
    } else if (normalizedPosition.x <= 0.5) {
        float area = triangle_area(controlPoints[0], controlPoints[2], controlPoints[3]);
        float b0 = triangle_area(normalizedPosition, controlPoints[2], controlPoints[3]) / area;
        float b1 = triangle_area(controlPoints[0], normalizedPosition, controlPoints[3]) / area;
        float b2 = triangle_area(controlPoints[0], controlPoints[2], normalizedPosition) / area;
//        return b0 * colors[0] + b1 * colors[2] + b2 * colors[3];
        return mix(mix(colors[0], colors[2], b1), colors[3], b2);
    } else {
        float area = triangle_area(controlPoints[0], controlPoints[1], controlPoints[2]);
        float b0 = triangle_area(normalizedPosition, controlPoints[1], controlPoints[2]) / area;
        float b1 = triangle_area(controlPoints[0], normalizedPosition, controlPoints[2]) / area;
        float b2 = triangle_area(controlPoints[0], controlPoints[1], normalizedPosition) / area;
//        return b0 * colors[0] + b1 * colors[1] + b2 * colors[2];
        return mix(mix(colors[0], colors[1], b1), colors[2], b2);
    }
}

float triangle_area(float2 p0, float2 p1, float2 p2) {
    float a = distance(p0, p1);
    float b = distance(p1, p2);
    float c = distance(p2, p0);
    float s = (a + b + c) / 2;
    return sqrt(s * (s - a) * (s - b) * (s - c));
}
