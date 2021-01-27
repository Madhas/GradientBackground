//
//  ViewController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 17.01.2021.
//

import UIKit
import simd

final class ViewController: UIViewController {
    
    private var gradientView: GradientView!
    private var bottomPanel: BottomPanelView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let config = GradientViewConfig(colors: Settings.shared.selectedColors)
        gradientView = GradientView(config: config)
        view.addSubview(gradientView)
        
        bottomPanel = BottomPanelView(frame: .zero)
        bottomPanel.addAnimate(target: self, action: #selector(animateGradient))
        bottomPanel.addSettings(target: self, action: #selector(showSettings))
        view.addSubview(bottomPanel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomHeight: CGFloat
        if #available(iOS 11, *) {
            bottomHeight = 48 + view.safeAreaInsets.bottom
        } else {
            bottomHeight = 48
        }
        
        bottomPanel.frame = CGRect(x: 0, y: view.bounds.maxY - bottomHeight, width: view.bounds.width, height: bottomHeight)
        gradientView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - bottomHeight)
    }

    @objc private func animateGradient() {
        let timing = CAMediaTimingFunction(name: .easeOut)
        gradientView.animate(with: 0.45, timingFunction: timing)
    }
    
    @objc private func showSettings() {
        let settings = SettingsController()
        let navigation = UINavigationController(rootViewController: settings)
        present(navigation, animated: true, completion: nil)
    }
}

