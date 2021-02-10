//
//  TimingCurveConstructorView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 07.02.2021.
//

import UIKit

private enum Constants {
    static let thumbSize = CGSize(width: 36, height: 36)
}

final class TimingCurveConstructorView: UIView {
    
    var currentTimingFunction: CAMediaTimingFunction {
        CAMediaTimingFunction(controlPoints: startPoint[0], startPoint[1], endPoint[0], endPoint[1])
    }
    
    private let shapeLayer = CAShapeLayer()
    private let startThumb = UIView()
    private let endThumb = UIView()
    private let xAxisView = UIImageView()
    private let yAxisView = UIImageView()
    private let startGuide = UIImageView()
    private let endGuide = UIImageView()
    
    private var startPoint: [Float] = [0.25, 0.25]
    private var endPoint: [Float] = [0.75, 0.75]
    
    private var currentPath: UIBezierPath {
        let w = bounds.width
        let h = bounds.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 3, y: h - 3))
        path.addCurve(to: CGPoint(x: w, y: 0),
                      controlPoint1: CGPoint(x: CGFloat(startPoint[0]) * w, y: CGFloat(1 - startPoint[1]) * h),
                      controlPoint2: CGPoint(x: CGFloat(endPoint[0]) * w, y: CGFloat(1 - endPoint[1]) * h))
        return path
    }
    
    var startGuideRotation: CGAffineTransform {
        CGAffineTransform(rotationAngle: atan(-(bounds.height - startThumb.frame.midY) / startThumb.frame.midX))
    }
    var startGuideSize: CGSize {
        CGSize(width: sqrt(pow(startThumb.frame.midX, 2) + pow(bounds.height - startThumb.frame.midY, 2)),
               height: guideImage.size.height)
    }
    
    var endGuideRotation: CGAffineTransform {
        CGAffineTransform(rotationAngle: atan(-endThumb.frame.midY / (bounds.width - endThumb.frame.midX)))
    }
    var endGuideSize: CGSize {
        CGSize(width: sqrt(pow(bounds.width - endThumb.frame.midX, 2) + pow(endThumb.frame.midY, 2)),
               height: guideImage.size.height)
    }
    
    private lazy var axisImage: UIImage = {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let ctx = UIGraphicsGetCurrentContext()!
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1))
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let capInsets =  UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        return image.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }()
    
    private lazy var guideImage: UIImage = {
        let dotSize: CGFloat = 3
        let space: CGFloat = 4
        
        let capInsets = UIEdgeInsets(top: 0, left: dotSize, bottom: 0, right: dotSize + space)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: dotSize * 3 + space * 2, height: dotSize))
        return renderer.image { context in
            let ctx = context.cgContext
            
            let centers = [CGPoint(x: dotSize / 2, y: dotSize / 2),
                           CGPoint(x: dotSize + space + dotSize / 2, y: dotSize / 2),
                           CGPoint(x: dotSize * 2 + space * 2 + dotSize / 2, y: dotSize / 2)]
            let dot1 = UIBezierPath(arcCenter: centers[0], radius: dotSize / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            let dot2 = UIBezierPath(arcCenter: centers[1], radius: dotSize / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            let dot3 = UIBezierPath(arcCenter: centers[2], radius: dotSize / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            
            ctx.addPath(dot1.cgPath)
            ctx.addPath(dot2.cgPath)
            ctx.addPath(dot3.cgPath)
            ctx.fillPath()
        }.withRenderingMode(.alwaysTemplate).resizableImage(withCapInsets: capInsets)
    }()
    
    private var blockLayout = false
    
    init(timingFunction: CAMediaTimingFunction) {
        super.init(frame: .zero)
        
        timingFunction.getControlPoint(at: 1, values: &startPoint)
        timingFunction.getControlPoint(at: 2, values: &endPoint)
        
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !blockLayout else { return }
        
        shapeLayer.frame = bounds
        shapeLayer.path = currentPath.cgPath
        
        yAxisView.center = CGPoint(x: 1.5, y: bounds.height)
        yAxisView.bounds.size = CGSize(width: bounds.height, height: 3)
        
        xAxisView.center = CGPoint(x: 0, y: bounds.height - 1.5)
        xAxisView.bounds.size = CGSize(width: bounds.width, height: 3)
        
        startThumb.center = CGPoint(x: CGFloat(startPoint[0]) * bounds.width, y: CGFloat(1 - startPoint[1]) * bounds.height)
        endThumb.center = CGPoint(x: CGFloat(endPoint[0]) * bounds.width, y: CGFloat(1 - endPoint[1]) * bounds.height)

        startGuide.center = CGPoint(x: guideImage.size.height / 2, y: bounds.height - guideImage.size.height / 2)
        startGuide.bounds.size = startGuideSize
        startGuide.transform = startGuideRotation
        
        endGuide.center = CGPoint(x: bounds.width - guideImage.size.height / 2, y: guideImage.size.height / 2)
        endGuide.bounds.size = endGuideSize
        endGuide.transform = endGuideRotation
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if startThumb.frame.contains(point) {
            return startThumb
        } else if endThumb.frame.contains(point) {
            return endThumb
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    // MARK: Public
    
    func set(timingFunction: CAMediaTimingFunction) {
        timingFunction.getControlPoint(at: 1, values: &startPoint)
        timingFunction.getControlPoint(at: 2, values: &endPoint)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: Private
    
    private func setupViews() {
        startGuide.image = guideImage
        startGuide.tintColor = .accent
        startGuide.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        addSubview(startGuide)
        
        endGuide.image = guideImage
        endGuide.tintColor = .accent
        endGuide.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        addSubview(endGuide)
        
        shapeLayer.lineWidth = 4
        shapeLayer.strokeColor = UIColor.mainColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
        
        xAxisView.image = axisImage
        xAxisView.tintColor = .secondaryColor
        xAxisView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        addSubview(xAxisView)
        
        yAxisView.image = axisImage
        yAxisView.tintColor = .secondaryColor
        yAxisView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        yAxisView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        addSubview(yAxisView)
        
        for view in [startThumb, endThumb] {
            let recognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
            view.addGestureRecognizer(recognizer)
            view.bounds.size = Constants.thumbSize
            view.clipsToBounds = false
            view.backgroundColor = .white
            view.layer.cornerRadius = Constants.thumbSize.height / 2
            view.layer.shadowOpacity = 0.4
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 4)
            view.layer.shadowPath = UIBezierPath(ovalIn: view.bounds).cgPath
            addSubview(view)
        }
    }
    
    @objc private func pan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        
        func clamp(_ t: CGPoint) -> CGPoint {
            let minDx = -view.center.x
            let maxDx = self.bounds.width - view.center.x
            
            let minDy = -view.center.y
            let maxDy = self.bounds.height - view.center.y
            
            return CGPoint(x: min(max(t.x, minDx), maxDx),
                           y: min(max(t.y, minDy), maxDy))
        }
        
        let t = clamp(recognizer.translation(in: self))
        let transform = CGAffineTransform(translationX: t.x, y: t.y)
        let currentPoint = view.center.applying(transform)
        
        switch recognizer.state {
        case .began:
            blockLayout = true
        case .changed:
            view.transform = transform
            let ctrlPoint = [Float(currentPoint.x / bounds.width),
                             Float((bounds.height - currentPoint.y) / bounds.height)]
            if view === startThumb {
                startPoint = ctrlPoint
            } else if view === endThumb {
                endPoint = ctrlPoint
            }
            shapeLayer.path = currentPath.cgPath
            
            startGuide.transform = startGuideRotation
            startGuide.bounds.size = startGuideSize
            endGuide.bounds.size = endGuideSize
            endGuide.transform = endGuideRotation
        case .ended, .cancelled:
            blockLayout = false
            view.transform = .identity
        default:
            break
        }
    }
}
