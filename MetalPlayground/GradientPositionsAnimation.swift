//
//  GradientViewAnimation.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 21.01.2021.
//

import UIKit

final class GradientPositionsAnimation: GradientAnimation<[SIMD2<Float>]> {
    
    override func nextValue(for t: TimeInterval) -> [SIMD2<Float>] {
        let ratio = timingFunction.y(at: Float(t))
        return fromValue.enumerated().map { idx, point -> SIMD2<Float> in
            let dx = (toValue[idx].x - fromValue[idx].x) * ratio
            let dy = (toValue[idx].y - fromValue[idx].y) * ratio
            return SIMD2(point.x + dx, point.y + dy)
        }
    }
}
