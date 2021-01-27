//
//  ColorSettingsCell.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class ColorSettingsCell: UICollectionViewCell {
    
    private let gradientView: GradientView
    private let titleContainerView: UIView
    private let titleLabel: UILabel
    
    override init(frame: CGRect) {
        let config = GradientViewConfig(colors: Settings.shared.selectedColors)
        gradientView = GradientView(config: config)
        titleContainerView = UIView()
        titleLabel = UILabel()
        
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(gradientView)
        
        titleContainerView.backgroundColor = .white
        addSubview(titleContainerView)
        
        titleLabel.text = "Edit colors"
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleContainerView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomHeight = min(34, bounds.height)
        titleContainerView.frame = CGRect(x: 0, y: bounds.maxY - bottomHeight, width: bounds.width, height: bottomHeight)
        
        let titleWidth = titleLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: bottomHeight)).width
        titleLabel.frame = CGRect(x: titleContainerView.bounds.midX - titleWidth / 2, y: 0, width: titleWidth, height: bottomHeight)
        
        gradientView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - bottomHeight)
    }
}
