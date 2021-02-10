//
//  CAMediaTimingFunction+Helpers.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 19.01.2021.
//

import UIKit

extension CAMediaTimingFunction {
    
    func ratio(for t: Float) -> Float {
        var p1: [Float] = [0, 0];
        var p2: [Float] = [0, 0]
        getControlPoint(at: 1, values: &p1)
        getControlPoint(at: 2, values: &p2)
        let ctrl1 = CGPoint(x: Double(p1[0]), y: Double(p1[1]))
        let ctrl2 = CGPoint(x: Double(p2[0]), y: Double(p2[1]))
        
        let a1 = pow((1 - t), 3) * CGPoint.zero
        let a2 = 3 * pow((1 - t), 2) * t * ctrl1
        let a3 = 3 * (1 - t) * pow(t, 2) * ctrl2
        let a4 = pow(t, 3) * CGPoint(x: 1, y: 1)
        let point = a1 + a2 + a3 + a4

        return Float(point.y)
    }
}

private extension CGPoint {

    static func *(lhs: Float, rhs: CGPoint) -> CGPoint {
        CGPoint(x: Double(lhs) * Double(rhs.x), y: Double(lhs) * Double(rhs.y))
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
