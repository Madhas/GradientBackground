//
//  TopHeaderView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 30.01.2021.
//

import UIKit

final class TopHeaderView: UIView {

    let actionButton: UIButton
    
    override init(frame: CGRect) {
        actionButton = UIButton(type: .system)
        
        super.init(frame: frame)
        
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        actionButton.setTitleColor(.mainColor, for: .normal)
        addSubview(actionButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height: CGFloat
        if #available(iOS 11, *) {
            height = bounds.height - safeAreaInsets.top
        } else {
            height = bounds.height
        }
        
        let actionWidth = actionButton.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: height)).width
        actionButton.frame = CGRect(x: bounds.maxX - actionWidth - 17,
                                   y: bounds.maxY - height,
                                   width: actionWidth,
                                   height: height)
    }
}
