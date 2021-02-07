//
//  TimingCurveSelectionCell.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 07.02.2021.
//

import UIKit

protocol TimingCurveSelectionCellDelegate: AnyObject {

    func timingCurveSelectionCell(_ cell: TimingCurveSelectionCell, didSelectTitle title: String, value: CAMediaTimingFunction?)
}

final class TimingCurveSelectionCell: UICollectionViewCell {
    
    weak var delegate: TimingCurveSelectionCellDelegate?
   
    private let picker: UIPickerView
    
    private let titles = ["Linear", "Ease In", "Ease Out", "Ease In Ease Out", "Custom"]
    private let values = [CAMediaTimingFunction(name: .linear),
                          CAMediaTimingFunction(name: .easeIn),
                          CAMediaTimingFunction(name: .easeOut),
                          CAMediaTimingFunction(name: .easeInEaseOut),
                          nil]
    
    override init(frame: CGRect) {
        picker = UIPickerView()
        
        super.init(frame: frame)
        
        picker.dataSource = self
        picker.delegate = self
        addSubview(picker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        picker.frame = bounds
    }
}

// MARK: UIPickerViewDataSource

extension TimingCurveSelectionCell: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titles.count
    }
}

// MARK: UIPickerViewDelegate

extension TimingCurveSelectionCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        titles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let title = titles[row]
        let value = values[row]
        
        delegate?.timingCurveSelectionCell(self, didSelectTitle: title, value: value)
    }
}
