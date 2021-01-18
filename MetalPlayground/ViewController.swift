//
//  ViewController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 17.01.2021.
//

import UIKit

class ViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        
        view = GradientView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(recognizer)
    }

    @objc private func tapped() {
        (view as! GradientView).toggleBlur()
    }
}

