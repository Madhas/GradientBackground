//
//  CAMediaTimingFunction+Helpers.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 19.01.2021.
//

import UIKit

extension CAMediaTimingFunction {
    
    func y(at x: Float) -> Float {
        var p1: [Float] = [0, 0];
        var p2: [Float] = [0, 0]
        getControlPoint(at: 1, values: &p1)
        getControlPoint(at: 2, values: &p2)
        
        // Since our function grows monotonically
        let eps: Float = 1 / 80
        
        var lower: Float = 0
        var upper: Float = 1
        var tn: Float = 0.5
        var xn = cubicBezier(for: (p1[0], p1[1]), p2: (p2[0], p2[1]), t: tn).x
        
        while abs(x - xn) > eps {
            if xn > x {
                upper = tn
            } else {
                lower = tn
            }
            
            tn = (upper + lower) / 2
            xn = cubicBezier(for: (p1[0], p1[1]), p2: (p2[0], p2[1]), t: tn).x
        }
        
        return cubicBezier(for: (p1[0], p1[1]), p2: (p2[0], p2[1]), t: tn).y
    }
    
    private func cubicBezier(for p1: (x: Float, y: Float), p2: (x: Float, y: Float), t: Float) -> (x: Float, y: Float) {
        let x = 3 * pow((1 - t), 2) * t * p1.x + 3 * (1 - t) * pow(t, 2) * p2.x + pow(t, 3)
        let y = 3 * pow((1 - t), 2) * t * p1.y + 3 * (1 - t) * pow(t, 2) * p2.y + pow(t, 3)
        
        return (x, y)
    }
}
