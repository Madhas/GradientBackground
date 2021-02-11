//
//  GradientView.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 17.01.2021.
//

import UIKit
#if !targetEnvironment(simulator)
import Metal
import MetalPerformanceShaders
import simd

// MARK: Original View

final class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    private var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }
    
    private let positions = GradientPositions()
    
    // Metal
    private var device: MTLDevice!
    private var renderPipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!
    private var blurShader: MPSImageGaussianBlur!

    private var currentControlPoints: [SIMD2<Float>]
    var controlPoints: [CGPoint] {
        currentControlPoints.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
    }
    
    private var colors: [SIMD4<Float>]
    
    private let vertices: [SIMD4<Float>] = [
        SIMD4(-1, 1, 0, 1), SIMD4(1, 1, 0, 1), SIMD4(-1, -1, 0, 1),
        SIMD4(1, 1, 0, 1), SIMD4(-1, -1, 0, 1), SIMD4(1, -1, 0, 1)
    ]
    
    // Animations
    private var positionsAnimation: GradientPositionsAnimation?
    private var colorsAnimation: GradientColorsAnimation?
    
    init(colors: [UIColor]) {
        currentControlPoints = positions.controlPoints
        self.colors = colors.compactMap { color -> SIMD4<Float>? in
            guard let components = color.cgColor.components, components.count == 4 else {
                return nil
            }
            return SIMD4<Float>(Float(components[0]), Float(components[1]), Float(components[2]), Float(components[3]))
        }
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
        render()
    }
    
    // MARK: Public
    
    func animatePositions(with duration: TimeInterval, timingFunction: CAMediaTimingFunction) {
        guard positionsAnimation == nil else { return }
        
        let timer = CADisplayLink(target: self, selector: #selector(tick))
        let nextPoints = positions.nextControlPoints
        positionsAnimation = GradientPositionsAnimation(startTime: CACurrentMediaTime(),
                                               duration: duration,
                                               timingFunction: timingFunction,
                                               fromValue: currentControlPoints,
                                               toValue: nextPoints,
                                               displayLink: timer)
        currentControlPoints = nextPoints
        
        timer.add(to: .main, forMode: .default)
    }
    
    func animateColors(_ colors: [UIColor], duration: TimeInterval, timingFunction: CAMediaTimingFunction) {
        guard colorsAnimation == nil else { return }
        
        let nextColors = colors.compactMap { color -> SIMD4<Float>? in
            guard let components = color.cgColor.components, components.count == 4 else {
                return nil
            }
            return SIMD4<Float>(Float(components[0]), Float(components[1]), Float(components[2]), Float(components[3]))
        }
        let timer = CADisplayLink(target: self, selector: #selector(tick))
        
        colorsAnimation = GradientColorsAnimation(startTime: CACurrentMediaTime(),
                                                  duration: duration,
                                                  timingFunction: timingFunction,
                                                  fromValue: self.colors,
                                                  toValue: nextColors,
                                                  displayLink: timer)
        self.colors = nextColors
        
        timer.add(to: .main, forMode: .default)
    }
    
    func set(colors: [UIColor]) {
        let newColors = colors.compactMap { color -> SIMD4<Float>? in
            guard let components = color.cgColor.components, components.count == 4 else {
                return nil
            }
            return SIMD4<Float>(Float(components[0]), Float(components[1]), Float(components[2]), Float(components[3]))
        }
        self.colors = newColors
        render()
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
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexProgram
        renderPipelineDescriptor.fragmentFunction = fragmentProgram
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        
        blurShader = MPSImageGaussianBlur(device: device, sigma: 35)
        blurShader.edgeMode = .clamp
    }
    
    @objc private func tick() {
        autoreleasepool {
            render()
        }
    }
    
    private func render() {
        let semaphore = DispatchSemaphore(value: GradientAnimationConstants.buffersCount)
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
        
        let controlPoints: [SIMD2<Float>]
        if let animation = positionsAnimation {
            controlPoints = animation.nextBuffer().map {
                SIMD2($0.x * Float(drawable.texture.width), $0.y * Float(drawable.texture.height))
            }
            if animation.finished {
                self.positionsAnimation = nil
            }
        } else {
            controlPoints = currentControlPoints.map {
                SIMD2($0.x * Float(drawable.texture.width), $0.y * Float(drawable.texture.height))
            }
        }
        
        let colors: [SIMD4<Float>]
        if let animation = colorsAnimation {
            colors = animation.nextBuffer()
            if animation.finished {
                colorsAnimation = nil
            }
        } else {
            colors = self.colors
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setVertexBytes(vertices, length: MemoryLayout.size(ofValue: vertices[0]) * vertices.count, index: 0)
        encoder.setFragmentBytes(colors, length: MemoryLayout.size(ofValue: colors[0]) * colors.count, index: 0)
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

#else

// MARK: Stub View

final class GradientView: UIView {
    
    private let label = UILabel()
    
    init(colors: [UIColor]) {
        super.init(frame: .zero)
        
        backgroundColor = .blue
        
        label.text = "Run on device"
        label.font = .systemFont(ofSize: 25)
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height: CGFloat = 30
        label.frame = CGRect(x: 0, y: bounds.midY - height / 2, width: bounds.width, height: height)
    }
    
    // Public Stubs
    
    let controlPoints: [CGPoint] = []
    
    func animatePositions(with duration: TimeInterval, timingFunction: CAMediaTimingFunction) {
    }
    
    func animateColors(_ colors: [UIColor], duration: TimeInterval, timingFunction: CAMediaTimingFunction) {
    }
    
    func set(colors: [UIColor]) {
    }
}

#endif
