//
//  EditColorsAnimator.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 30.01.2021.
//

import UIKit

final class EditColorsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Transition {
        case present(ColorSettingsCell)
        case dismiss(ColorSettingsCell)
    }
    
    private let transition: Transition
    
    init(transition: Transition) {
        self.transition = transition
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transition {
        case let .present(cell):
            animatePresent(transitionContext: transitionContext, cell: cell)
        case let .dismiss(cell):
            animateDismiss(transitionContext: transitionContext, cell: cell)
        }
    }
    
    private func animatePresent(transitionContext: UIViewControllerContextTransitioning, cell: ColorSettingsCell) {
        guard let toController = transitionContext.viewController(forKey: .to) as? EditColorsController,
              let fromController = transitionContext.viewController(forKey: .from),
              let gradientView = cell.gradientView else {
            return
        }
        let containerView = transitionContext.containerView
        
        let fromFrame = containerView.convert(gradientView.frame, from: gradientView.superview)
        gradientView.removeFromSuperview()
        gradientView.setHandles(hidden: false)
        toController.view.addSubview(gradientView)
        toController.gradientView = gradientView
        cell.gradientView = nil
        
        toController.topPanel?.frame.size.width = containerView.bounds.width
        if #available(iOS 11, *) {
            toController.topPanel?.frame.origin.y = -(toController.topHeight + containerView.safeAreaInsets.top)
        } else {
            toController.topPanel?.frame.origin.y = -toController.topHeight
        }
        toController.topPanel?.layoutIfNeeded()
        
        toController.bottomPanel?.frame.size.width = containerView.bounds.width
        toController.bottomPanel?.frame.origin.y = toController.view.bounds.height
        toController.bottomPanel?.layoutIfNeeded()
        
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
    
    private func animateDismiss(transitionContext: UIViewControllerContextTransitioning, cell: ColorSettingsCell) {
        guard let fromController = transitionContext.viewController(forKey: .from) as? EditColorsController,
              let toController = transitionContext.viewController(forKey: .to),
              let gradientView = fromController.gradientView,
              let topPanel = fromController.topPanel,
              let bottomPanel = fromController.bottomPanel else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        topPanel.removeFromSuperview()
        bottomPanel.removeFromSuperview()
        gradientView.removeFromSuperview()
        containerView.addSubview(topPanel)
        containerView.addSubview(bottomPanel)
        containerView.addSubview(gradientView)
        fromController.topPanel = nil
        fromController.gradientView = nil
        fromController.bottomPanel = nil
        
        gradientView.setHandles(hidden: true)
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration) {
            toController.view.transform = .identity
            gradientView.frame = fromController.view.convert(cell.gradientFrame, from: cell)
            topPanel.frame.origin.y = -topPanel.bounds.height
            bottomPanel.frame.origin.y = containerView.bounds.height
        } completion: {
            gradientView.removeFromSuperview()
            cell.addSubview(gradientView)
            cell.gradientView = gradientView
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            transitionContext.completeTransition($0)
        }

    }
}
