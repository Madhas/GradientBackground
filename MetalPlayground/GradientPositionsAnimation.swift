//
//  GradientViewAnimation.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 21.01.2021.
//

import UIKit

final class GradientPositionsAnimation: GradientAnimation<[SIMD2<Float>]> {
    
    override func nextValue(for t: TimeInterval) -> [SIMD2<Float>] {
        let ratio = timingFunction.slopeFor(t: Float(t))
        return fromValue.enumerated().map { idx, point -> SIMD2<Float> in
            let dx = (toValue[idx].x - fromValue[idx].x) * Float(t) * ratio
            let dy = (toValue[idx].y - fromValue[idx].y) * Float(t) * ratio
            return SIMD2(point.x + dx, point.y + dy)
        }
    }
}
