//
//  GradientAnimation.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 07.02.2021.
//

import UIKit

enum GradientAnimationConstants {
    static let buffersCount = 3
}

class GradientAnimation<T> {
    
    private(set) var finished = false
    
    private let startTime: TimeInterval
    private let duration: TimeInterval
    private let displayLink: CADisplayLink
    
    let timingFunction: CAMediaTimingFunction
    let fromValue: T
    let toValue: T
    
    private var currentBuffer = 0
    private var animationBuffers: [T?] = Array(repeating: nil, count: GradientAnimationConstants.buffersCount)
    
    init(startTime: TimeInterval,
         duration: TimeInterval,
         timingFunction: CAMediaTimingFunction,
         fromValue: T,
         toValue: T,
         displayLink: CADisplayLink) {
        self.startTime = startTime
        self.duration = duration
        self.timingFunction = timingFunction
        self.fromValue = fromValue
        self.toValue = toValue
        self.displayLink = displayLink
    }
    
    func nextBuffer() -> T {
        defer { currentBuffer = (currentBuffer + 1) % GradientAnimationConstants.buffersCount }
        
        let t = (CACurrentMediaTime() - startTime) / duration
        if t > 1 {
            displayLink.invalidate()
            finished = true
            return toValue
        } else {
            let nextBuffer = nextValue(for: t)
            animationBuffers[currentBuffer] = nextBuffer
            return nextBuffer
        }
    }
    
    // MARK: Override
    
    func nextValue(for t: TimeInterval) -> T {
        fatalError("Subclasses must override the method")
    }
}
