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
        SIMD2(0.356, 0.246),
        SIMD2(0.825, 0.082),
        SIMD2(0.185, 0.92),
        SIMD2(0.649, 0.756)
    ]
    
    private let intermediatePoints: [SIMD2<Float>] = [
        SIMD2(0.266, 0.582),
        SIMD2(0.413, 0.836),
        SIMD2(0.734, 0.419),
        SIMD2(0.588, 0.165)
    ]
    
    // Transforms
    private var currentStep: Float = 0
    private let stepsCount: Float = 4
    
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
    
    func nextTransforms(for viewport: CGSize) -> [simd_float3x3] {
        let flooredStep = floor(currentStep)
        let source = currentStep == flooredStep ? controlPoints : intermediatePoints
        let destination = currentStep == flooredStep ? intermediatePoints : controlPoints
        var transforms: [simd_float3x3] = []
        transforms.reserveCapacity(source.count)
        
        let ctrlIdx = Int(flooredStep)
        for index in 0 ..< source.count {
            let tx = (destination[ctrlIdx].x - source[ctrlIdx].x) * Float(viewport.width)
            let ty = (destination[ctrlIdx].y - source[ctrlIdx].y) * Float(viewport.height)
            transforms[index] = simd_float3x3(SIMD3(1, 0, tx), SIMD3(0, 1, ty), SIMD3(0, 0, 1))
        }
        
        currentStep = (currentStep + 0.5).truncatingRemainder(dividingBy: stepsCount)
        return transforms
    }
}
