//
//  GradientView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 17.01.2021.
//

import UIKit
import Metal
import MetalPerformanceShaders
import simd

final class GradientView: UIView {

    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    private var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }
    
    private let config: GradientViewConfig
    
    private var device: MTLDevice!
    private var renderPipelineState: MTLRenderPipelineState!
    private var computePipelineState: MTLComputePipelineState!
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!
    private var drawableCopy: MTLTexture!
    private var blurShader: MPSImageGaussianBlur!

    private let vertices: [SIMD4<Float>] = [
        SIMD4(-1, 1, 0, 1), SIMD4(1, 1, 0, 1), SIMD4(-1, -1, 0, 1),
        SIMD4(1, 1, 0, 1), SIMD4(-1, -1, 0, 1), SIMD4(1, -1, 0, 1)
    ]
    
    // Animations
    private var animation: GradientViewAnimation?
    private var currentControlPoints: [SIMD2<Float>]
    
    init(config: GradientViewConfig) {
        self.config = config
        currentControlPoints = config.controlPoints
        super.init(frame: .zero)
        
        setupMetal()
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        metalLayer.drawableSize = bounds.size
        
        }
        
        render()
    }
    
    // MARK: Public
    
    func animate(with duration: TimeInterval, timingFunction: CAMediaTimingFunction) {
        guard animation == nil else {
            return
        }
        
        let timer = CADisplayLink(target: self, selector: #selector(tick))
        let nextPoints = config.nextControlPoints
        animation = GradientViewAnimation(startTime: CACurrentMediaTime(),
                                               duration: duration,
                                               timingFunction: timingFunction,
                                               startPoints: currentControlPoints,
                                               targetPoints: nextPoints,
                                               displayLink: timer)
        currentControlPoints = nextPoints
        
        timer.add(to: .main, forMode: .default)
    }
    
    // MARK: Setup
    
    private func setupMetal() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        library = device.makeDefaultLibrary()!
        
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = false
        
        let vertexProgram = library.makeFunction(name: "vertex_shader")!
        let fragmentProgram = library.makeFunction(name: "fragment_shader")!
        let computeProgram = library.makeFunction(name: "displaceTexture")!
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexProgram
        renderPipelineDescriptor.fragmentFunction = fragmentProgram
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        
        computePipelineState = try! device.makeComputePipelineState(function: computeProgram)
        
        blurShader = MPSImageGaussianBlur(device: device, sigma: 35)
        blurShader.edgeMode = .clamp
    }
    
    @objc private func tick() {
        autoreleasepool {
            render()
        }
    }
    
    private func render() {
        let semaphore = DispatchSemaphore(value: GradientViewAnimation.buffersCount)
        semaphore.wait()
        guard let drawable = metalLayer.nextDrawable() else {
            semaphore.signal()
            return
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let clearWhite = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = clearWhite
        
        var controlPoints: [SIMD2<Float>]
        if let animation = animation {
            controlPoints = animation.nextBuffer().map {
                SIMD2($0.x * Float(drawable.texture.width), $0.y * Float(drawable.texture.height))
            }
            if animation.finished {
                self.animation = nil
            }
        } else {
            controlPoints = currentControlPoints.map {
                SIMD2($0.x * Float(drawable.texture.width), $0.y * Float(drawable.texture.height))
            }
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setVertexBytes(vertices, length: MemoryLayout.size(ofValue: vertices[0]) * vertices.count, index: 0)
        encoder.setFragmentBytes(config.colors, length: MemoryLayout.size(ofValue: config.colors[0]) * config.colors.count, index: 0)
        encoder.setFragmentBytes(controlPoints,
                                 length: MemoryLayout.size(ofValue: controlPoints[0]) * controlPoints.count,
                                 index: 1)
        
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        encoder.endEncoding()
        
        blurShader.encode(commandBuffer: commandBuffer, inPlaceTexture: &renderPassDescriptor.colorAttachments[0].texture!, fallbackCopyAllocator: nil)
        
        commandBuffer.addCompletedHandler { _ in
            semaphore.signal()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
