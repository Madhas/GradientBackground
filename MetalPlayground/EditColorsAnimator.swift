//
//  EditColorsAnimator.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 30.01.2021.
//

import UIKit

final class EditColorsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let gradientView: GradientView
    private let isPresenting: Bool
    
    init(gradientView: GradientView, isPresenting: Bool) {
        self.gradientView = gradientView
        self.isPresenting = isPresenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresenting(using: transitionContext)
        }
    }
    
    private func animatePresenting(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toController = transitionContext.viewController(forKey: .to) as? EditColorsController, let fromController = transitionContext.viewController(forKey: .from) else {
            return
        }
        let containerView = transitionContext.containerView
        
        let fromFrame = containerView.convert(gradientView.frame, from: gradientView.superview)
        gradientView.removeFromSuperview()
        gradientView.setHandles(hidden: false)
        toController.view.addSubview(gradientView)
        toController.gradientView = gradientView
        
        toController.containerView.frame.origin.y = toController.view.bounds.height
        containerView.addSubview(toController.view)
        toController.view.frame = fromFrame
        gradientView.frame = toController.view.bounds
        
        let duration = transitionDuration(using: transitionContext)
        toController.view.setNeedsLayout()
        UIView.animate(withDuration: duration) {
            fromController.view.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            toController.view.frame = containerView.bounds
            toController.view.layoutIfNeeded()
        } completion: {
            transitionContext.completeTransition($0)
        }

    }
}
