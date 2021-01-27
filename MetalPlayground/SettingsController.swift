//
//  SettingsController.swift
//  MetalPlayground
//
//  Created by Андрей Овсянников on 27.01.2021.
//

import UIKit

class SettingsController: UIViewController {
    
    private var collectionView: UICollectionView!

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
}