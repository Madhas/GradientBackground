//
//  BottomPanelView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 26.01.2021.
//

import UIKit

final class MainBottomPanelView: UIView {

    private let animateButton: UIButton
    private let settingsButton: UIButton
    
    override init(frame: CGRect) {
        animateButton = UIButton(type: .system)
        settingsButton = UIButton(type: .custom)
        
        super.init(frame: frame)
        
        animateButton.setTitleColor(.mainColor, for: .normal)
        animateButton.setTitle("Animate", for: .normal)
        animateButton.titleLabel?.font = .systemFont(ofSize: 17)
        animateButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        addSubview(animateButton)
        
        settingsButton.setImage(.settings24, for: .normal)
        settingsButton.imageView?.tintColor = .mainColor
        addSubview(settingsButton)
        
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = animateButton.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.height)).width
        animateButton.frame = CGRect(x: bounds.midX - width / 2, y: 0, width: width, height: bounds.height)
        
        let size: CGFloat = 32
        settingsButton.frame = CGRect(x: bounds.maxX - size - 8, y: 12, width: size, height: size)
    }
    
    func addAnimate(target: Any, action: Selector) {
        animateButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func addSettings(target: Any, action: Selector) {
        settingsButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
