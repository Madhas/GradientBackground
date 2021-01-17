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

private struct ControlColor {
    let color: simd_float4
    let point: simd_float2
}

final class GradientView: UIView {

    override class var layerClass: AnyClass {
        CAMetalLayer.self
    }
    
    private var metalLayer: CAMetalLayer {
        layer as! CAMetalLayer
    }
    
    private var device: MTLDevice!
    private var pipelineState: MTLRenderPipelineState!
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!
    
    private var vertexBuffer: MTLBuffer!
    private let vertices: [Float] = [
        -1,  1, 0, 1,
         1, -1, 0, 1,
         1,  1, 0, 1,
        
        -1,  1, 0, 1,
         1, -1, 0, 1,
        -1, -1, 0, 1,
    ]
    
    private var colorsBuffer: MTLBuffer!
    private let colors: [simd_float4] = [
        simd_float4(254 / 255, 244 / 255, 202 / 255, 1),
        simd_float4(135 / 255, 162 / 255, 132 / 255, 1),
        simd_float4(66 / 255, 109 / 255,  87 / 255, 1),
        simd_float4(247 / 255, 227 / 255, 139 / 255, 1)
    ]
    
    private var controlPointsBuffer: MTLBuffer!
    private let controlPoints: [simd_float2] = [
        simd_float2(0.356, 0.246),
        simd_float2(0.825, 0.082),
        simd_float2(0.185, 0.92),
        simd_float2(0.649, 0.756)
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
        controlPointsBuffer = device.makeBuffer(bytes: controlPoints, length: MemoryLayout.size(ofValue: controlPoints[0]) * controlPoints.count, options: [])
        
        let vertexProgram = library.makeFunction(name: "vertex_shader")!
        let fragmentProgram = library.makeFunction(name: "fragment_shader")!
        
        let desc = MTLRenderPipelineDescriptor()
        desc.vertexFunction = vertexProgram
        desc.fragmentFunction = fragmentProgram
        desc.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineState = try! device.makeRenderPipelineState(descriptor: desc)
        
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
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(colorsBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(controlPointsBuffer, offset: 0, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
