//
//  TimingCurveConstructorCell.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 09.02.2021.
//

import UIKit

final class TimingCurveConstructorCell: UICollectionViewCell {
    
    var selectedTimingFunction: CAMediaTimingFunction {
        constructorView.currentTimingFunction
    }
    
    private let constructorView: TimingCurveConstructorView
    
    override init(frame: CGRect) {
        constructorView = TimingCurveConstructorView()
        
        super.init(frame: frame)
        
        addSubview(constructorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        constructorView.frame = CGRect(x: 18, y: 8, width: bounds.width - 18 * 2, height: bounds.height - 8 * 2)
    }
    
    func configure(with function: CAMediaTimingFunction) {
        constructorView.set(timingFunction: function)
    }
}
