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
    
    private var startPoint: [Float] = [0.25, 0.25]
    private var endPoint: [Float] = [0.75, 0.75]
    private var currentPath: UIBezierPath {
        let w = bounds.width
        let h = bounds.height
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: h))
        path.addCurve(to: CGPoint(x: w, y: 0),
                      controlPoint1: CGPoint(x: CGFloat(startPoint[0]) * w, y: CGFloat(1 - startPoint[1]) * h),
                      controlPoint2: CGPoint(x: CGFloat(endPoint[0]) * w, y: CGFloat(1 - endPoint[1]) * h))
        return path
    }
    
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
        
        startThumb.center = CGPoint(x: CGFloat(startPoint[0]) * bounds.width, y: CGFloat(1 - startPoint[1]) * bounds.height)
        endThumb.center = CGPoint(x: CGFloat(endPoint[0]) * bounds.width, y: CGFloat(1 - endPoint[1]) * bounds.height)
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
        shapeLayer.lineWidth = 4
        shapeLayer.strokeColor = UIColor.mainColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
        
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
        case .ended, .cancelled:
            blockLayout = false
            view.transform = .identity
        default:
            break
        }
    }
}
