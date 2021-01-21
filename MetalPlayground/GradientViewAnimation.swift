//
//  GradientViewAnimation.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 21.01.2021.
//

import UIKit

struct GradientViewAnimation {
    static let buffersCount = 3
    
    private(set) var finished = false
    
    private let startTime: TimeInterval
    private let duration: TimeInterval
    private let timingFunction: CAMediaTimingFunction
    private let startPoints: [SIMD2<Float>]
    private let targetPoints: [SIMD2<Float>]
    private let displayLink: CADisplayLink
    
    private var currentBuffer = 0
    private var animationBuffers: [[SIMD2<Float>]] = Array(repeating: [], count: GradientViewAnimation.buffersCount)
    
    init(startTime: TimeInterval,
         duration: TimeInterval,
         timingFunction: CAMediaTimingFunction,
         startPoints: [SIMD2<Float>],
         targetPoints: [SIMD2<Float>],
         displayLink: CADisplayLink) {
        self.startTime = startTime
        self.duration = duration
        self.timingFunction = timingFunction
        self.startPoints = startPoints
        self.targetPoints = targetPoints
        self.displayLink = displayLink
    }
    
    mutating func nextBuffer() -> [SIMD2<Float>] {
        defer { currentBuffer = (currentBuffer + 1) % GradientViewAnimation.buffersCount }
        
        let t = (CACurrentMediaTime() - startTime) / duration
        if t > 1 {
            displayLink.invalidate()
            finished = true
            return targetPoints
        } else {
            let previousIdx = currentBuffer == 0 ? GradientViewAnimation.buffersCount - 1 : currentBuffer - 1
            let previousBuffer = animationBuffers[previousIdx].isEmpty ? startPoints : animationBuffers[previousIdx]
            let ratio = timingFunction.slopeFor(t: Float(t))
            let nextBuffer = previousBuffer.enumerated().map { idx, point -> SIMD2<Float> in
                let dx = (targetPoints[idx].x - startPoints[idx].x) * Float(t) * ratio
                let dy = (targetPoints[idx].y - startPoints[idx].y) * Float(t) * ratio
                return SIMD2(point.x + dx, point.y + dy)
            }
            animationBuffers[currentBuffer] = nextBuffer
            return nextBuffer
        }
    }
}
