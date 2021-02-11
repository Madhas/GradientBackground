//
//  ColorSelectionView.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 04.02.2021.
//

import UIKit

final class ColorSelectionView: UIView {
    
    private let rInput = UITextField()
    private let gInput = UITextField()
    private let bInput = UITextField()
    private let colorButton = UIButton(type: .custom)
    
    var isEditing: Bool {
        rInput.isEditing || gInput.isEditing || bInput.isEditing
    }
    
    var selectedColor: UIColor {
        colorButton.backgroundColor ?? .black
    }
    
    init(currentColor: UIColor) {
        super.init(frame: .zero)
        
        setup()
        
        if let components = currentColor.cgColor.components {
            colorButton.backgroundColor = currentColor
            
            let r = floor(components[0] * 255)
            let g = floor(components[1] * 255)
            let b = floor(components[2] * 255)
            rInput.text = "\(Int(r))"
            gInput.text = "\(Int(g))"
            bInput.text = "\(Int(b))"
            
            updateButtonColor(r: Float(r), g: Float(g), b: Float(b))
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let colorSide = bounds.height - 12 * 2
        colorButton.frame = CGRect(x: bounds.maxX - 12 - colorSide, y: 12, width: colorSide, height: colorSide)
        colorButton.layer.cornerRadius = colorSide / 2
        
        let inputInset: CGFloat = 10
        let interitemInset: CGFloat = 8
        let textHeight: CGFloat = 30
        let width = colorButton.frame.minX - inputInset * 2
        let textWidth = width / 3 - interitemInset * 2
        let textY = bounds.midY - textHeight / 2
        
        rInput.frame = CGRect(x: 10, y: textY, width: textWidth, height: textHeight)
        gInput.frame = CGRect(x: rInput.frame.maxX + interitemInset, y: textY, width: textWidth, height: textHeight)
        bInput.frame = CGRect(x: gInput.frame.maxX + interitemInset, y: textY, width: textWidth, height: textHeight)
    }
    
    func addAccept(target: Any, action: Selector) {
        colorButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func stopEditing() {
        if rInput.isFirstResponder {
            rInput.resignFirstResponder()
        } else if gInput.isFirstResponder {
            gInput.resignFirstResponder()
        } else if bInput.isFirstResponder {
            bInput.resignFirstResponder()
        }
    }
    
    // MARK: Private
    
    private func setup() {
        backgroundColor = .white
        
        rInput.placeholder = "R"
        rInput.textAlignment = .center
        rInput.delegate = self
        rInput.keyboardType = .numberPad
        rInput.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        addSubview(rInput)
        
        gInput.placeholder = "G"
        gInput.textAlignment = .center
        gInput.delegate = self
        gInput.keyboardType = .numberPad
        gInput.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        addSubview(gInput)
        
        bInput.placeholder = "B"
        bInput.textAlignment = .center
        bInput.delegate = self
        bInput.keyboardType = .numberPad
        bInput.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        addSubview(bInput)
        
        colorButton.setImage(.colorOk36, for: .normal)
        addSubview(colorButton)
    }
    
    private func updateButtonColor(r: Float, g: Float, b: Float) {
        let relativeLuminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        colorButton.imageView?.tintColor = relativeLuminance < 128 ? .white : .black
    }
    
    @objc private func editingChanged(_ textField: UITextField) {
        guard let red = Float(rInput.text?.count == 0 ? "0" : (rInput.text ?? "0")),
              let green = Float(gInput.text?.count == 0 ? "0" : (gInput.text ?? "0")),
              let blue = Float(bInput.text?.count == 0 ? "0" : (bInput.text ?? "0")) else {
            return
        }
        
        colorButton.backgroundColor = UIColor(red: CGFloat(red / 255),
                                              green: CGFloat(green / 255),
                                              blue: CGFloat(blue / 255),
                                              alpha: 1)
        updateButtonColor(r: red, g: green, b: blue)
    }
}

// MARK: UITextFieldDelegate

extension ColorSelectionView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0, let text = textField.text, let number = Float(text + string), number > 255 {
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, let number = Float(text), number > 255 {
            textField.text = nil
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
