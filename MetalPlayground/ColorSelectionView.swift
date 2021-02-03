//
//  ColorSelectionView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 04.02.2021.
//

import UIKit

final class ColorSelectionView: UIView {
    
    private let textField: UITextField
    private let colorView: UIView!

    override init(frame: CGRect) {
        textField = UITextField()
        colorView = UIView()
        
        super.init(frame: frame)
        
        backgroundColor = .white
        
        textField.placeholder = "Enter hex color"
        textField.delegate = self
        addSubview(textField)
        
        colorView.backgroundColor = .black
        addSubview(colorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let colorSide = bounds.height - 12 * 2
        colorView.frame = CGRect(x: bounds.maxX - 12 - colorSide, y: 12, width: colorSide, height: colorSide)
        colorView.layer.cornerRadius = colorSide / 2
        
        let textHeight: CGFloat = 30
        textField.frame = CGRect(x: 10, y: bounds.midY - textHeight / 2, width: colorView.frame.minX - 10, height: textHeight)
    }
}

// MARK: UITextFieldDelegate

extension ColorSelectionView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        if text.count == 0, range.length == 0 {
            textField.text = "#" + string
            return false
        } else if text.starts(with: "#"), range.length == 1, range.location == 1 {
            textField.text = ""
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
