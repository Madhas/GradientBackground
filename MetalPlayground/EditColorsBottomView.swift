//
//  EditColorsBottomView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 30.01.2021.
//

import UIKit

final class EditColorsBottomView: UIView {

    let applyButton: UIButton
    let defaultsButton: UIButton
    
    var blockLayoutSubviews = false

    override init(frame: CGRect) {
        applyButton = UIButton(type: .system)
        defaultsButton = UIButton(type: .system)
        
        super.init(frame: frame)
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 17)
        applyButton.setTitleColor(.mainColor, for: .normal)
        addSubview(applyButton)
        
        defaultsButton.setTitle("Defaults", for: .normal)
        defaultsButton.titleLabel?.font = .systemFont(ofSize: 17)
        defaultsButton.setTitleColor(.mainColor, for: .normal)
        addSubview(defaultsButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !blockLayoutSubviews else { return }
        
        let height: CGFloat
        if #available(iOS 11, *) {
            height = bounds.height - safeAreaInsets.bottom
        } else {
            height = bounds.height
        }
        
        applyButton.frame = CGRect(x: 0, y: 0, width: bounds.width / 2, height: height)
        defaultsButton.frame = CGRect(x: bounds.width / 2,
                                      y: 0,
                                      width: bounds.width / 2,
                                      height: height)
    }
}
