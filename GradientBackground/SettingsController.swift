//
//  SettingsController.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 27.01.2021.
//

import UIKit

protocol SettingsControllerDelegate: AnyObject {

    func settingsController(_ controller: SettingsController, didChangeColors colors: [UIColor])
}

final class SettingsController: UIViewController {
    
    weak var delegate: SettingsControllerDelegate?
    
    private var collectionView: UICollectionView!
    private var fixedContentOffset: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Settings"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem?.tintColor = .mainColor
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        collectionView.register(ColorSettingsCell.self,
                                forCellWithReuseIdentifier: String(describing: ColorSettingsCell.self))
        collectionView.register(TimingCurveSettingsCell.self,
                                forCellWithReuseIdentifier: String(describing: TimingCurveSettingsCell.self))
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource

extension SettingsController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ColorSettingsCell.self), for: indexPath)
        case 1:
            return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TimingCurveSettingsCell.self), for: indexPath)
        default:
            fatalError("Unexpected number of cells")
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension SettingsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 250)
        case 1:
            return CGSize(width: collectionView.bounds.width, height: 48)
        default:
            fatalError("Unexpected number of cells")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch indexPath.item {
        case 0:
            let controller = EditColorsController()
            controller.modalPresentationStyle = .custom
            controller.transitioningDelegate = self
            controller.delegate = self
            controller.shouldLoadGradientView = false
            present(controller, animated: true, completion: nil)
        case 1:
            let controller = TimingCurveController()
            controller.delegate = self
            let navigation = UINavigationController(rootViewController: controller)
            present(navigation, animated: true, completion: nil)
        default:
            fatalError("Unexpected number of cells")
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension SettingsController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return EditColorsPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let cell = collectionView.visibleCells.first(where: { $0 is ColorSettingsCell }) as? ColorSettingsCell else {
            return nil
        }
        
        if #available(iOS 13, *) {
        } else if #available(iOS 11, *) {
            fixedContentOffset = collectionView.contentOffset
        }
        return EditColorsAnimator(transition: .present(cell))
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let cell = collectionView.visibleCells.first(where: { $0 is ColorSettingsCell }) as? ColorSettingsCell else {
            return nil
        }
        
        return EditColorsAnimator(transition: .dismiss(cell)) { [weak self] in
            if let offset = self?.fixedContentOffset {
                self?.collectionView.contentOffset = offset
                self?.fixedContentOffset = nil
            }
        }
    }
}

// MARK: EditColorsControllerDelegate

extension SettingsController: EditColorsControllerDelegate {
    
    func editColorsController(_ controller: EditColorsController, didChangeColors colors: [UIColor]) {
        delegate?.settingsController(self, didChangeColors: colors)
    }
}

// MARK: TimingCurveControllerDelegate

extension SettingsController: TimingCurveControllerDelegate {
    
    func timingCurveController(_ controller: TimingCurveController, didChangeTimingFunctionName name: String) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TimingCurveSettingsCell else {
            return
        }
        
        cell.update(value: name)
    }
}
