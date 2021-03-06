//
//  ViewController.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 17.01.2021.
//

import UIKit
import simd

final class ViewController: UIViewController {
    
    private var gradientView: GradientView!
    private var bottomPanel: MainBottomPanelView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientView = GradientView(colors: Settings.shared.selectedColors)
        view.addSubview(gradientView)
        
        bottomPanel = MainBottomPanelView(frame: .zero)
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
        let timing = Settings.shared.selectedTimingFunction
        gradientView.animatePositions(with: 0.45, timingFunction: timing)
    }
    
    @objc private func showSettings() {
        let settings = SettingsController()
        settings.delegate = self
        let navigation = UINavigationController(rootViewController: settings)
        present(navigation, animated: true, completion: nil)
    }
}

// MARK: SettingsControllerDelegate

extension ViewController: SettingsControllerDelegate {
    
    func settingsController(_ controller: SettingsController, didChangeColors colors: [UIColor]) {
        gradientView.set(colors: colors)
    }
}
