//
//  EditColorsController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class EditColorsController: UIViewController {
    
    let topHeight: CGFloat = 48
    let bottomHeight: CGFloat = 48
    
    var shouldLoadGradientView = true
    
    var gradientView: GradientView?
    var topPanel: TopHeaderView?
    var bottomPanel: EditColorsBottomView?
    
    private var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldLoadGradientView {
            let config = GradientViewConfig(colors: Settings.shared.selectedColors)
            let gradientView = GradientView(config: config)
            view.addSubview(gradientView)
            self.gradientView = gradientView
        }
        
        let topPanel = TopHeaderView()
        topPanel.clipsToBounds = true
        topPanel.backgroundColor = .white
        topPanel.actionButton.setTitle("Close", for: .normal)
        topPanel.actionButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(topPanel)
        self.topPanel = topPanel
        
        let bottomPanel = EditColorsBottomView()
        bottomPanel.clipsToBounds = true
        bottomPanel.backgroundColor = .white
        view.addSubview(bottomPanel)
        self.bottomPanel = bottomPanel
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let topPanel = self.topPanel, let gradientView = self.gradientView, let bottomPanel = self.bottomPanel else {
            return
        }
        
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
        
        gradientView.frame = CGRect(x: 0,
                                     y: topHeight,
                                     width: view.bounds.width,
                                     height: view.bounds.height - bottomHeight - topHeight)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}
