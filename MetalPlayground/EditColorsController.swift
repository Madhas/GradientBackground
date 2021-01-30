//
//  EditColorsController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class EditColorsController: UIViewController {
    
    let topHeight: CGFloat = 48
    private let bottomHeight: CGFloat = 48
    
    var shouldLoadGradientView = true
    
    var gradientView: GradientView?
    var topPanel: UIView!
    var bottomPanel: UIView!
    
    private var closeButton: UIButton!
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
        
        topPanel = UIView()
        topPanel.backgroundColor = .white
        view.addSubview(topPanel)
        
        bottomPanel = UIView()
        bottomPanel.backgroundColor = .white
        view.addSubview(bottomPanel)
        
        closeButton = UIButton(type: .system)
        closeButton.frame.origin.x = view.bounds.maxX
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 17)
        closeButton.setTitleColor(.mainColor, for: .normal)
        topPanel.addSubview(closeButton)
        
        applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 17)
        applyButton.setTitleColor(.mainColor, for: .normal)
        bottomPanel.addSubview(applyButton)
        
        defaultsButton = UIButton(type: .system)
        defaultsButton.setTitle("Defaults", for: .normal)
        defaultsButton.titleLabel?.font = .systemFont(ofSize: 17)
        defaultsButton.setTitleColor(.mainColor, for: .normal)
        bottomPanel.addSubview(defaultsButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topHeight: CGFloat
        let bottomHeight: CGFloat
        if #available(iOS 11, *) {
            topHeight = self.topHeight + view.safeAreaInsets.top
            bottomHeight = self.bottomHeight + view.safeAreaInsets.bottom
        } else {
            topHeight = self.topHeight
            bottomHeight = self.bottomHeight
        }
        
        topPanel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topHeight)
        bottomPanel.frame = CGRect(x: 0,
                                     y: view.bounds.height - bottomHeight,
                                     width: view.bounds.width,
                                     height: bottomHeight)
        
        gradientView?.frame = CGRect(x: 0,
                                     y: topHeight,
                                     width: view.bounds.width,
                                     height: view.bounds.height - bottomHeight - topHeight)
        
        let closeWidth = closeButton.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: self.topHeight)).width
        closeButton.frame = CGRect(x: topPanel.bounds.maxX - closeWidth - 12,
                                   y: topPanel.bounds.maxY - self.topHeight, width: closeWidth, height: self.topHeight)
        applyButton.frame = CGRect(x: 0, y: 0, width: bottomPanel.bounds.width / 2, height: self.bottomHeight)
        defaultsButton.frame = CGRect(x: bottomPanel.bounds.width / 2,
                                      y: 0,
                                      width: bottomPanel.bounds.width / 2,
                                      height: self.bottomHeight)
    }
}
