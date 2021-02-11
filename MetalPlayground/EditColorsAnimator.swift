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
    private let completion: (() -> Void)?
    
    init(transition: Transition, completion: (() -> Void)? = nil) {
        self.transition = transition
        self.completion = completion
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.32
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
        
        let topPanelHeight: CGFloat
        let bottomPanelHeight: CGFloat
        if #available(iOS 12, *) {
            topPanelHeight = toController.topHeight + containerView.safeAreaInsets.top
            bottomPanelHeight = toController.bottomHeight + containerView.safeAreaInsets.bottom
        } else if #available(iOS 11, *) {
            topPanelHeight = toController.topHeight + fromController.view.safeAreaInsets.top
            bottomPanelHeight = toController.bottomHeight + fromController.view.safeAreaInsets.bottom
        } else {
            topPanelHeight = toController.topHeight + fromController.topLayoutGuide.length
            bottomPanelHeight = toController.bottomHeight
        }
        
        let fromFrame = containerView.convert(gradientView.frame, from: gradientView.superview)
        gradientView.removeFromSuperview()
        gradientView.frame = fromFrame
        containerView.addSubview(gradientView)
        cell.gradientView = nil
        
        let gradientTargetFrame = CGRect(x: 0,
                                         y: topPanelHeight,
                                         width: containerView.bounds.width,
                                         height: containerView.bounds.height - topPanelHeight - bottomPanelHeight)
        
        toController.view.frame = containerView.bounds
        
        toController.topPanel?.frame.origin.y = topPanelHeight
        toController.topPanel?.frame.size = CGSize(width: containerView.bounds.width, height: 0)
        
        toController.bottomPanel?.frame.origin.y = gradientTargetFrame.maxY
        toController.bottomPanel?.frame.size = CGSize(width: containerView.bounds.width, height: 0)
        
        containerView.addSubview(toController.view)
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                fromController.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.65) {
                gradientView.frame = gradientTargetFrame
                #if targetEnvironment(simulator)
                gradientView.layoutIfNeeded()
                #endif
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.65, relativeDuration: 0.35) {
                toController.topPanel?.frame.origin.y = 0
                toController.topPanel?.frame.size.height = topPanelHeight
                
                toController.bottomPanel?.frame.size.height = bottomPanelHeight
            }
        } completion: {
            gradientView.removeFromSuperview()
            toController.view.addSubview(gradientView)
            toController.gradientView = gradientView
            transitionContext.completeTransition($0)
            
            self.completion?()
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
        
        let previousTransform = toController.view.transform
        toController.view.transform = .identity
        if #available(iOS 13, *) {}
        else if #available(iOS 10, *) {
            toController.view.setNeedsLayout()
            toController.view.layoutIfNeeded()
        }
        let gradientTargetFrame = containerView.convert(cell.gradientFrame, from: cell)
        toController.view.transform = previousTransform
        
        topPanel.blockLayoutSubviews = true
        bottomPanel.blockLayoutSubviews = true
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                toController.view.transform = .identity
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.35) {
                topPanel.frame.origin.y = topPanel.bounds.height
                topPanel.frame.size.height = 0
                
                bottomPanel.frame.size.height = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.65) {
                gradientView.frame = gradientTargetFrame
                #if targetEnvironment(simulator)
                gradientView.layoutIfNeeded()
                #endif
            }
        } completion: {
            gradientView.removeFromSuperview()
            cell.addSubview(gradientView)
            cell.gradientView = gradientView
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            transitionContext.completeTransition($0)
            
            self.completion?()
        }
    }
}
