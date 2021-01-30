//
//  Settings.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class Settings {

    static let shared = Settings()
    
    private var colors: [UIColor]?
    private var timingFunction: CAMediaTimingFunction?
    private var timingFunctionName: String?
    
    var selectedColors: [UIColor] {
        let defaultColors = [UIColor(red: 254 / 255, green: 244 / 255, blue: 202 / 255, alpha: 1),
                             UIColor(red: 66 / 255, green: 109 / 255, blue: 87 / 255, alpha: 1),
                             UIColor(red: 247 / 255, green: 227 / 255, blue: 139 / 255, alpha: 1),
                             UIColor(red: 135 / 255, green: 162 / 255, blue: 132 / 255, alpha: 1)]
        return colors ?? defaultColors
    }
    
    var selectedTimingFunctionName: String {
        return timingFunctionName ?? "Ease Out"
    }
    
    var selectedTimingFunction: CAMediaTimingFunction {
        return timingFunction ?? CAMediaTimingFunction(name: .easeOut)
    }
}
