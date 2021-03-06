//
//  GradientColorsAnimation.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 07.02.2021.
//

import Foundation
import simd

final class GradientColorsAnimation: GradientAnimation<[SIMD4<Float>]> {
    
    override func nextValue(for t: TimeInterval) -> [SIMD4<Float>] {
        let ratio = timingFunction.y(at: Float(t))
        return fromValue.enumerated().map { idx, color in
            return mix(color, toValue[idx], t: ratio)
        }
    }
}
