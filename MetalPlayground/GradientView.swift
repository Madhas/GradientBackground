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

private struct VertexIn {
    let position: SIMD4<Float>
    let displacementColor: SIMD4<Float>
}

final class GradientView: UIView {

    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    private var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }
    
    private var device: MTLDevice!
    private var renderPipelineState: MTLRenderPipelineState!
    private var computePipelineState: MTLComputePipelineState!
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!
    private var displacementMapTexture: MTLTexture!
    private var drawableCopy: MTLTexture!

    private var vertexBuffer: MTLBuffer!
    private let vertices: [VertexIn] = {
        let color1 = SIMD4<Float>(171 / 255, 171 / 255, 0, 1)
        let color2 = SIMD4<Float>(0, 128 / 255, 0, 1)
        let color3 = SIMD4<Float>(128 / 255, 0, 0, 1)
        let color4 = SIMD4<Float>(0, 128 / 255, 0, 1)
        
        return [
            VertexIn(position: SIMD4(-1, 1, 0, 1), displacementColor: color1),
            VertexIn(position: SIMD4(1, 1, 0, 1), displacementColor: color1),
            VertexIn(position: SIMD4(-1, 0, 0, 1), displacementColor: color1),
            
            VertexIn(position: SIMD4(1, 1, 0, 1), displacementColor: color2),
            VertexIn(position: SIMD4(-1, 0, 0, 1), displacementColor: color2),
            VertexIn(position: SIMD4(1, 0, 0, 1), displacementColor: color2),
            
            VertexIn(position: SIMD4(-1, 0, 0, 1), displacementColor: color3),
            VertexIn(position: SIMD4(1, 0, 0, 1), displacementColor: color3),
            VertexIn(position: SIMD4(-1, -1, 0, 1), displacementColor: color3),
            
            VertexIn(position: SIMD4(1, 0, 0, 1), displacementColor: color4),
            VertexIn(position: SIMD4(-1, -1, 0, 1), displacementColor: color4),
            VertexIn(position: SIMD4(1, -1, 0, 1), displacementColor: color4)
        ]
    }()
    
    private var colorsBuffer: MTLBuffer!
    private let colors: [SIMD4<Float>] = [
        SIMD4(254 / 255, 244 / 255, 202 / 255, 1),
        SIMD4(135 / 255, 162 / 255, 132 / 255, 1),
        SIMD4(66 / 255, 109 / 255,  87 / 255, 1),
        SIMD4(247 / 255, 227 / 255, 139 / 255, 1)
    ]
    
    private var controlPointsBuffer: MTLBuffer!
    private let controlPoints: [SIMD2<Float>] = [
        SIMD2(0.356, 0.246),
        SIMD2(0.825, 0.082),
        SIMD2(0.185, 0.92),
        SIMD2(0.649, 0.756)
    ]
    
    var displayLink: CADisplayLink!
    
    override init(frame: CGRect) {
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
        
        if (controlPointsBuffer == nil) {
            let controlPoints = self.controlPoints.map { point in
                SIMD2(point.x * Float(self.bounds.width), point.y * Float(self.bounds.height))
            }
            controlPointsBuffer = device.makeBuffer(bytes: controlPoints, length: MemoryLayout.size(ofValue: controlPoints[0]) * controlPoints.count, options: [])
            
            let textureDescriptor = MTLTextureDescriptor()
            textureDescriptor.pixelFormat = .bgra8Unorm
            textureDescriptor.width = Int(self.bounds.width)
            textureDescriptor.height = Int(self.bounds.height)
            textureDescriptor.usage = [.renderTarget, .shaderRead]
            displacementMapTexture = device.makeTexture(descriptor: textureDescriptor)
            
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
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout.size(ofValue: vertices[0]) * vertices.count, options: [])
        colorsBuffer = device.makeBuffer(bytes: colors, length: MemoryLayout.size(ofValue: colors[0]) * colors.count, options: [])
        
        let vertexProgram = library.makeFunction(name: "vertex_shader")!
        let fragmentProgram = library.makeFunction(name: "fragment_shader")!
        let computeProgram = library.makeFunction(name: "displaceTexture")!
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexProgram
        renderPipelineDescriptor.fragmentFunction = fragmentProgram
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[1].pixelFormat = .bgra8Unorm
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
        
        if let texture = displacementMapTexture {
            renderPassDescriptor.colorAttachments[1].texture = texture
            renderPassDescriptor.colorAttachments[1].loadAction = .dontCare
            renderPassDescriptor.colorAttachments[1].storeAction = .dontCare
            renderPassDescriptor.colorAttachments[1].clearColor = clearWhite
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(colorsBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(controlPointsBuffer, offset: 0, index: 1)
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
            
            let compute = commandBuffer.makeComputeCommandEncoder()!
            compute.setComputePipelineState(computePipelineState)
            compute.setTexture(drawable.texture, index: 0)
            compute.setTexture(displacementMapTexture, index: 1)
            compute.setTexture(drawable.texture, index: 2)
            
            let w = computePipelineState.threadExecutionWidth;
            let h = computePipelineState.maxTotalThreadsPerThreadgroup / w;
            let threadsPerThreadgroup = MTLSize(width: w, height: h, depth: 1);
            let threadgroupsPerGrid = MTLSize(width: (drawable.texture.width + w - 1) / w,
                                              height: (drawable.texture.height + h - 1) / h,
                                              depth: 1)
            
            compute.dispatchThreadgroups(threadsPerThreadgroup, threadsPerThreadgroup: threadgroupsPerGrid)
            compute.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    private var usesBlur = false
    func toggleBlur() {
        usesBlur.toggle()
    }
}
