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

    private let vertices: [SIMD4<Float>] = [
        SIMD4(-1, 1, 0, 1), SIMD4(1, 1, 0, 1), SIMD4(-1, -1, 0, 1),
        SIMD4(1, 1, 0, 1), SIMD4(-1, -1, 0, 1), SIMD4(1, -1, 0, 1)
    ]
    
    var displayLink: CADisplayLink!
    
    init(config: GradientViewConfig) {
        self.config = config
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        config = GradientViewConfig(colors: [SIMD4<Float>(254 / 255, 244 / 255, 202 / 255, 1),
                                             SIMD4<Float>(135 / 255, 162 / 255, 132 / 255, 1),
                                             SIMD4<Float>(66 / 255, 109 / 255,  87 / 255, 1),
                                             SIMD4<Float>(247 / 255, 227 / 255, 139 / 255, 1)])
        super.init(frame: frame)
        
        setupMetal()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        metalLayer.drawableSize = bounds.size
        metalLayer.framebufferOnly = false
        
        if drawableCopy == nil {
            let textureDescriptor = MTLTextureDescriptor()
            textureDescriptor.pixelFormat = .bgra8Unorm
            textureDescriptor.width = Int(self.bounds.width)
            textureDescriptor.height = Int(self.bounds.height)
            textureDescriptor.usage = .shaderRead
            drawableCopy = device.makeTexture(descriptor: textureDescriptor)
        }
    }
    
    // MARK: Setup
    
    private func setupMetal() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        library = device.makeDefaultLibrary()!
        
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        
        let vertexProgram = library.makeFunction(name: "vertex_shader")!
        let fragmentProgram = library.makeFunction(name: "fragment_shader")!
        let computeProgram = library.makeFunction(name: "displaceTexture")!
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexProgram
        renderPipelineDescriptor.fragmentFunction = fragmentProgram
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        
        computePipelineState = try! device.makeComputePipelineState(function: computeProgram)
        
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.add(to: .main, forMode: .default)
    }
    
    @objc private func tick() {
        autoreleasepool {
            render()
        }
    }
    
    private func render() {
        guard let drawable = metalLayer.nextDrawable() else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let clearWhite = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = clearWhite
        
        let mappedControlPoints = config.controlPoints.map { point -> SIMD2<Float> in
            SIMD2(point.x * Float(drawable.texture.width), point.y * Float(drawable.texture.height))
        }
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setVertexBytes(vertices, length: MemoryLayout.size(ofValue: vertices[0]) * vertices.count, index: 0)
        encoder.setFragmentBytes(config.colors, length: MemoryLayout.size(ofValue: config.colors[0]) * config.colors.count, index: 0)
        encoder.setFragmentBytes(mappedControlPoints, length: MemoryLayout.size(ofValue: mappedControlPoints[0]) * mappedControlPoints.count, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        encoder.endEncoding()
        
        let blur = MPSImageGaussianBlur(device: device, sigma: 30)
        blur.edgeMode = .clamp
        blur.encode(commandBuffer: commandBuffer, inPlaceTexture: &renderPassDescriptor.colorAttachments[0].texture!, fallbackCopyAllocator: nil)

        if usesBlur {
//            let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
//            blitEncoder.copy(from: drawable.texture,
//                             sourceSlice: 0,
//                             sourceLevel: 0,
//                             sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
//                             sourceSize: MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1),
//                             to: drawableCopy,
//                             destinationSlice: 0,
//                             destinationLevel: 0,
//                             destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
//            blitEncoder.endEncoding()
//            
//            let compute = commandBuffer.makeComputeCommandEncoder()!
//            compute.setComputePipelineState(computePipelineState)
//            compute.setTexture(drawableCopy, index: 0)
//            compute.setTexture(drawable.texture, index: 1)
//            
//            let w = computePipelineState.threadExecutionWidth;
//            let h = computePipelineState.maxTotalThreadsPerThreadgroup / w;
//            let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1);
//            let threadgroupsPerGrid = MTLSize(width: (drawable.texture.width + w - 1) / w,
//                                              height: (drawable.texture.height + h - 1) / h,
//                                              depth: 1)
//            
//            compute.dispatchThreadgroups(threadsPerThreadgroup, threadsPerThreadgroup: threadgroupsPerGrid)
//            compute.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private var usesBlur = false
    func toggleBlur() {
        usesBlur.toggle()
    }
}
