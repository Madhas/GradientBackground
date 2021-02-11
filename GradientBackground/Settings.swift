//
//  Settings.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 27.01.2021.
//

import UIKit

final class Settings {
    
    private let colorsKey = "SettingsColorsKey"
    private let timingFunctionKey =  "SettingsTimingFunctionKey"
    private let timingFunctionNameKey = "SettingsTimingFunctionNameKey"

    static let shared = Settings()
    
    private var colors: [UIColor]?
    private var timingFunction: CAMediaTimingFunction?
    private var timingFunctionName: String?
    
    private var pendingChanges = false
    private let queue = DispatchQueue(label: "com.home.SettingsQueue")
    
    init() {
        loadValues()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var selectedColors: [UIColor] {
        return colors ?? defaultColors
    }
    
    var defaultColors: [UIColor] {
        [UIColor(red: 254 / 255, green: 244 / 255, blue: 202 / 255, alpha: 1),
         UIColor(red: 66 / 255, green: 109 / 255, blue: 87 / 255, alpha: 1),
         UIColor(red: 247 / 255, green: 227 / 255, blue: 139 / 255, alpha: 1),
         UIColor(red: 135 / 255, green: 162 / 255, blue: 132 / 255, alpha: 1)]
    }
    
    var selectedTimingFunctionName: String {
        return timingFunctionName ?? "Ease Out"
    }
    
    var selectedTimingFunction: CAMediaTimingFunction {
        return timingFunction ?? CAMediaTimingFunction(name: .easeOut)
    }
    
    var isTimingFunctionCustom: Bool {
        return selectedTimingFunctionName == "Custom"
    }
    
    func set(colors: [UIColor]) {
        self.colors = colors
        pendingChanges = true
    }
    
    func set(timingFunction: CAMediaTimingFunction, name: String) {
        self.timingFunction = timingFunction
        self.timingFunctionName = name
        pendingChanges = true
    }
    
    // MARK: Private
    
    private func loadValues() {
        let userDefaults = UserDefaults.standard
        
        if let colors = userDefaults.array(forKey: colorsKey) as? [[String: Float]] {
            self.colors = colors.map { dict in
                let r = dict["r"]!
                let g = dict["g"]!
                let b = dict["b"]!
                return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
            }
        }
        
        if let controlPoints = userDefaults.array(forKey: timingFunctionKey) as? [Float] {
            timingFunction = CAMediaTimingFunction(controlPoints: controlPoints[0],
                                                   controlPoints[1],
                                                   controlPoints[2],
                                                   controlPoints[3])
        }
        
        timingFunctionName = userDefaults.string(forKey: timingFunctionNameKey)
    }
    
    @objc private func willResignActive() {
        guard pendingChanges else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let defaults = UserDefaults.standard
            if let colors = self.colors {
                let storedColors = colors.map { color -> [String: Float] in
                    var red: CGFloat = 0
                    var green: CGFloat = 0
                    var blue: CGFloat = 0
                    color.getRed(&red, green: &green, blue: &blue, alpha: nil)
                    return ["r": Float(red), "g": Float(green), "b": Float(blue)]
                }
                
                defaults.setValue(storedColors, forKey: self.colorsKey)
            }
            
            if let timing = self.timingFunction {
                var ctrl1: [Float] = [0, 0]
                var ctrl2: [Float] = [0, 0]
                timing.getControlPoint(at: 1, values: &ctrl1)
                timing.getControlPoint(at: 2, values: &ctrl2)
                
                defaults.setValue(ctrl1 + ctrl2, forKey: self.timingFunctionKey)
            }
            
            if let timingName = self.timingFunctionName {
                defaults.setValue(timingName, forKey: self.timingFunctionNameKey)
            }
        }
    }
}
