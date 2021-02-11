//
//  EditColorsPresentationController.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 30.01.2021.
//

import UIKit

final class EditColorsPresentationController: UIPresentationController {
    
    lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.frame = containerView?.bounds ?? .zero
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0
        
        return dimmingView
    }()

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        dimmingView.frame = containerView?.bounds ?? .zero
        dimmingView.backgroundColor = .black
        dimmingView.alpha = 0
        
        containerView?.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.5
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
    
    override func dismissalTransitionWillBegin() {
        containerView?.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}
