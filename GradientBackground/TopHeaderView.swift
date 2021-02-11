//
//  TopHeaderView.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 30.01.2021.
//

import UIKit

final class TopHeaderView: UIView {

    let actionButton: UIButton
    
    var blockLayoutSubviews = false
    var topInset: CGFloat = 0
    
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
        
        guard !blockLayoutSubviews else { return }
        
        let height: CGFloat
        if #available(iOS 11, *) {
            height = bounds.height - safeAreaInsets.top - topInset
        } else {
            height = bounds.height - topInset
        }
        
        let actionWidth = actionButton.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: height)).width
        actionButton.frame = CGRect(x: bounds.maxX - actionWidth - 17,
                                   y: bounds.maxY - height,
                                   width: actionWidth,
                                   height: height)
    }
}
