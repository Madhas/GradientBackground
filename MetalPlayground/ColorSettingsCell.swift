//
//  ColorSettingsCell.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class ColorSettingsCell: UICollectionViewCell {
    
    private let bottomHeight: CGFloat = 48
    
    var gradientView: GradientView?
    
    private let titleContainerView: UIView
    private let titleLabel: UILabel
    private let separatorView: UIView
    
    override init(frame: CGRect) {
        let config = GradientViewConfig(colors: Settings.shared.selectedColors)
        gradientView = GradientView(config: config)
        titleContainerView = UIView()
        titleLabel = UILabel()
        separatorView = UIView()
        
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(gradientView!)
        addSubview(titleContainerView)
        
        gradientView?.clipsToBounds = true
        
        titleLabel.text = "Edit colors"
        titleLabel.font = .systemFont(ofSize: 17)
        titleContainerView.addSubview(titleLabel)
        
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.gray.withAlphaComponent(0.3) : .white
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.gray.withAlphaComponent(0.3) : .white
        }
    }
    
    var gradientFrame: CGRect {
        let bottomHeight = min(self.bottomHeight, bounds.height)
        return CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - bottomHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomHeight = min(self.bottomHeight, bounds.height)
        titleContainerView.frame = CGRect(x: 0, y: bounds.maxY - bottomHeight, width: bounds.width, height: bottomHeight)
        
        let titleWidth = titleLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: bottomHeight)).width
        titleLabel.frame = CGRect(x: 14, y: 0, width: titleWidth, height: bottomHeight)
        
        gradientView?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - bottomHeight)
        
        let pixel = 1 / UIScreen.main.scale
        separatorView.frame = CGRect(x: 14, y: bounds.maxY - pixel, width: bounds.width - 14, height: pixel)
    }
}
