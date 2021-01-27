//
//  GradientHandleView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class GradientHandleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.white.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = bounds.width * 0.12
    }
}
