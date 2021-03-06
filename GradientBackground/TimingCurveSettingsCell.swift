//
//  TimingCurveSettingsCell.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 27.01.2021.
//

import UIKit

final class TimingCurveSettingsCell: UICollectionViewCell {
    
    private let titleLabel: UILabel
    private let valueLabel: UILabel
    
    override init(frame: CGRect) {
        titleLabel = UILabel()
        valueLabel = UILabel()
        
        super.init(frame: frame)
        
        titleLabel.text = "Timing Curve"
        titleLabel.font = .systemFont(ofSize: 17)
        addSubview(titleLabel)
        
        valueLabel.text = Settings.shared.selectedTimingFunctionName
        valueLabel.font = .systemFont(ofSize: 17)
        valueLabel.textColor = .darkGray
        valueLabel.textAlignment = .right
        addSubview(valueLabel)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueWidth = valueLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: bounds.height)).width
        valueLabel.frame = CGRect(x: bounds.maxX - valueWidth - 14, y: 0, width: valueWidth, height: bounds.height)
        
        let titleWidth = valueLabel.frame.minX - 14
        titleLabel.frame = CGRect(x: 14, y: 0, width: titleWidth, height: bounds.height)
    }
    
    func update(value: String) {
        valueLabel.text = value
        setNeedsLayout()
    }
}
