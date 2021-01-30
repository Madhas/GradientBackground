//
//  EditColorsController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class EditColorsController: UIViewController {
    
    private let bottomHeight: CGFloat = 48
    
    var shouldLoadGradientView = true
    
    var gradientView: GradientView?
    var containerView: UIView!
    
    private var applyButton: UIButton!
    private var defaultsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldLoadGradientView {
            let config = GradientViewConfig(colors: Settings.shared.selectedColors)
            let gradientView = GradientView(config: config)
            view.addSubview(gradientView)
            self.gradientView = gradientView
        }
        
        containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        
        applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 17)
        applyButton.setTitleColor(.mainColor, for: .normal)
        containerView.addSubview(applyButton)
        
        defaultsButton = UIButton(type: .system)
        defaultsButton.setTitle("Defaults", for: .normal)
        defaultsButton.titleLabel?.font = .systemFont(ofSize: 17)
        defaultsButton.setTitleColor(.mainColor, for: .normal)
        containerView.addSubview(defaultsButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomHeight: CGFloat
        if #available(iOS 11, *) {
            bottomHeight = self.bottomHeight + view.safeAreaInsets.bottom
        } else {
            bottomHeight = self.bottomHeight
        }
        
        containerView.frame = CGRect(x: 0,
                                     y: view.bounds.height - bottomHeight,
                                     width: view.bounds.width,
                                     height: bottomHeight)
        gradientView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - bottomHeight)
        
        applyButton.frame = CGRect(x: 0, y: 0, width: containerView.bounds.width / 2, height: self.bottomHeight)
        defaultsButton.frame = CGRect(x: containerView.bounds.width / 2,
                                      y: 0,
                                      width: containerView.bounds.width / 2,
                                      height: self.bottomHeight)
    }
}
