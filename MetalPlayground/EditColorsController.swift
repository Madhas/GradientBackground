//
//  EditColorsController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

final class EditColorsController: UIViewController {
    
    let topHeight: CGFloat = 48
    let bottomHeight: CGFloat = 48
    private let colorSelectionHeight: CGFloat = 80
    
    var shouldLoadGradientView = true
    
    var gradientView: GradientView? {
        didSet {
            if let gradientView = gradientView {
                gradientView.handlesAdd(target: self, action: #selector(handleTapped(_:)))
            } else {
                gradientView?.handlesRemove(target: self, action: #selector(handleTapped(_:)))
            }
        }
    }
    
    var topPanel: TopHeaderView?
    var bottomPanel: EditColorsBottomView?
    
    weak private var colorSelectionView: ColorSelectionView?
    
    private var closeButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldLoadGradientView {
            let config = GradientViewConfig(colors: Settings.shared.selectedColors)
            let gradientView = GradientView(config: config)
            view.addSubview(gradientView)
            self.gradientView = gradientView
        }
        
        let topPanel = TopHeaderView()
        topPanel.clipsToBounds = true
        topPanel.backgroundColor = .white
        topPanel.actionButton.setTitle("Close", for: .normal)
        topPanel.actionButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(topPanel)
        self.topPanel = topPanel
        
        let bottomPanel = EditColorsBottomView()
        bottomPanel.clipsToBounds = true
        bottomPanel.backgroundColor = .white
        view.addSubview(bottomPanel)
        self.bottomPanel = bottomPanel
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(recognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topHeight: CGFloat
        let bottomHeight: CGFloat
        if #available(iOS 11, *) {
            topHeight = self.topHeight + view.safeAreaInsets.top
            bottomHeight = self.bottomHeight + view.safeAreaInsets.bottom
        } else {
            topHeight = self.topHeight
            bottomHeight = self.bottomHeight
        }
        
        if let topPanel = self.topPanel {
            topPanel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topHeight)
        }
        
        if let bottomPanel = self.bottomPanel {
            bottomPanel.frame = CGRect(x: 0,
                                        y: view.bounds.height - bottomHeight,
                                        width: view.bounds.width,
                                        height: bottomHeight)
        }
        
        if let gradientView = self.gradientView {
            gradientView.frame = CGRect(x: 0,
                                         y: topHeight,
                                         width: view.bounds.width,
                                         height: view.bounds.height - bottomHeight - topHeight)
        }
    }
    
    // MARK: Actions
    
    @objc private func viewTapped() {
        guard let view = colorSelectionView else { return }
    
        if view.isEditing {
            view.endEditing(false)
        } else {
            let bottomHeight = bottomPanel?.bounds.height ?? 0
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                view.frame.origin.y = self.view.bounds.height - bottomHeight
            } completion: { _ in
                view.removeFromSuperview()
            }
        }
    }
    
    @objc private func closeTapped() {
        if let colorSelection = colorSelectionView {
            let bottomHeight = bottomPanel?.bounds.height ?? 0
            UIView.animate(withDuration: 0.1) {
                colorSelection.frame.origin.y = self.view.bounds.height - bottomHeight
            } completion: { _ in
                colorSelection.removeFromSuperview()
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTapped(_ recognizer: UITapGestureRecognizer) {
        guard colorSelectionView == nil,
              let handle = recognizer.view as? GradientHandleView,
              let bottomHeight = bottomPanel?.bounds.height else {
            return
        }
        
        let rect = CGRect(x: 0, y: view.bounds.height - bottomHeight, width: view.bounds.width, height: colorSelectionHeight)
        let colorSelector = ColorSelectionView(currentColor: handle.backgroundColor ?? .black)
        colorSelector.frame = rect
        view.addSubview(colorSelector)
        
        colorSelectionView = colorSelector
        bottomPanel?.layer.zPosition = 1
        
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            colorSelector.frame.origin.y = self.view.bounds.height - bottomHeight - self.colorSelectionHeight
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let endFrame = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let colorSelection = colorSelectionView,
              endFrame.minY < colorSelection.frame.maxY else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            colorSelection.frame.origin.y -= (colorSelection.frame.maxY - endFrame.minY)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let colorSelection = colorSelectionView,
              let duration = notification.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let bottomPanel = bottomPanel else {
            return
        }
        
        
        let difference = (bottomPanel.frame.minY - self.colorSelectionHeight) - colorSelection.frame.minY
        UIView.animate(withDuration: duration) {
            colorSelection.frame.origin.y += difference
        }
    }
}
