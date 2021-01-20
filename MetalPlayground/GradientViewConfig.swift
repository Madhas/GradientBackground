//
//  GradientViewConfig.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 20.01.2021.
//

import UIKit
import simd

final class GradientViewConfig {
    
    let colors: [SIMD4<Float>]
    let controlPoints: [SIMD2<Float>] = [
        SIMD2(0.361, 0.249),
        SIMD2(0.185, 0.92),
        SIMD2(0.648, 0.757),
        SIMD2(0.824, 0.082)
    ]
    
    private let intermediatePoints: [SIMD2<Float>] = [
        SIMD2(0.266, 0.582),
        SIMD2(0.413, 0.836),
        SIMD2(0.734, 0.419),
        SIMD2(0.588, 0.165)
    ]
    
    // Transforms
    private var currentStep: Int = 0
    private let stepsCount: Int = 8
    
    init(colors: [SIMD4<Float>]) {
        self.colors = colors    }
    
    convenience init(colors: [CGColor]) {
        let components = colors.compactMap { color -> SIMD4<Float>? in
            guard let components = color.components, components.count == 4 else {
                return nil
            }
            return SIMD4<Float>(Float(components[0]), Float(components[1]), Float(components[2]), Float(components[3]))
        }
        
        assert(components.count == 4)
        self.init(colors: components)
    }
    
    var nextControlPoints: [SIMD2<Float>] {
        defer { currentStep = (currentStep + 1) % stepsCount }
        let source = currentStep % 2 == 0 ? intermediatePoints : controlPoints
        let shift = (currentStep + 1) / 2
        
        if shift == 0 {
            return source
        } else {
            return Array(source[shift ..< source.count] + source[0 ..< shift])
        }
    }
}
