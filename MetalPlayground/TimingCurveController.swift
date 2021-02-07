//
//  TimingCurveController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 07.02.2021.
//

import UIKit

protocol TimingCurveControllerDelegate: AnyObject {

    func timingCurveController(_ controller: TimingCurveController, didChangeTimingFunctionName name: String)
}

final class TimingCurveController: UIViewController {
    
    weak var delegate: TimingCurveControllerDelegate?
    
    private var selectedName: String?
    private var selectedCurve: CAMediaTimingFunction?
    
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        collectionView.register(TimingCurveSelectionCell.self, forCellWithReuseIdentifier: String(describing: TimingCurveSelectionCell.self))
    }

    // MARK: Actions
    
    @objc private func close() {
        if let name = selectedName, let curve = selectedCurve {
            Settings.shared.set(timingFunction: curve, name: name)
            delegate?.timingCurveController(self, didChangeTimingFunctionName: name)
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource

extension TimingCurveController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TimingCurveSelectionCell.self), for: indexPath) as! TimingCurveSelectionCell
            cell.delegate = self
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
    }
}
