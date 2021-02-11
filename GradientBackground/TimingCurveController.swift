//
//  TimingCurveController.swift
//  GradientBackground
//
//  Created by Andrey Ovsyannikov on 07.02.2021.
//

import UIKit

protocol TimingCurveControllerDelegate: AnyObject {

    func timingCurveController(_ controller: TimingCurveController, didChangeTimingFunctionName name: String)
}

final class TimingCurveController: UIViewController {
    
    weak var delegate: TimingCurveControllerDelegate?
    
    private var isEditorShown = false
    private var selectedName: String? = Settings.shared.selectedTimingFunctionName
    private var selectedCurve: CAMediaTimingFunction?
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEditorShown = Settings.shared.isTimingFunctionCustom
        
        title = "Timing Curve"
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
        
        collectionView.register(TimingCurveSelectionCell.self,
                                forCellWithReuseIdentifier: String(describing: TimingCurveSelectionCell.self))
        collectionView.register(TimingCurveConstructorCell.self,
                                forCellWithReuseIdentifier: String(describing: TimingCurveConstructorCell.self))
    }

    // MARK: Actions
    
    @objc private func close() {
        if let name = selectedName {
            if let curve = selectedCurve {
                Settings.shared.set(timingFunction: curve, name: name)
                delegate?.timingCurveController(self, didChangeTimingFunctionName: name)
            } else if isEditorShown, let cell = collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TimingCurveConstructorCell {
                Settings.shared.set(timingFunction: cell.selectedTimingFunction, name: name)
                delegate?.timingCurveController(self, didChangeTimingFunctionName: name)
            }
        }
            
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource

extension TimingCurveController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isEditorShown ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TimingCurveSelectionCell.self), for: indexPath) as! TimingCurveSelectionCell
            cell.delegate = self
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TimingCurveConstructorCell.self), for: indexPath) as! TimingCurveConstructorCell
            if Settings.shared.isTimingFunctionCustom {
                cell.configure(with: Settings.shared.selectedTimingFunction)
            }
            return cell
        default:
            fatalError("Unexpected number of cells")
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension TimingCurveController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.item {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: 200)
        case 1:
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width - 10 * 2)
        default:
            fatalError("Unexpected number of cells")
        }
    }
}

// MARK: TimingCurveSelectionCellDelegate

extension TimingCurveController: TimingCurveSelectionCellDelegate {
    
    func timingCurveSelectionCell(_ cell: TimingCurveSelectionCell, didSelectTitle title: String, value: CAMediaTimingFunction?) {
        selectedName = title
        selectedCurve = value
        
        if value == nil && !isEditorShown {
            collectionView.performBatchUpdates({
                isEditorShown = true
                collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
            }, completion: nil)
        } else if value != nil && isEditorShown {
            isEditorShown = false
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [IndexPath(item: 1, section: 0)])
            }, completion: nil)

        }
    }
}
