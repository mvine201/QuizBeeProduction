//
//  Extension+UICollectionView.swift
//  Quiz Bee
//
//  Created by Mạc Văn Vinh on 11/4/26.
//

import UIKit

extension UICollectionView {
    
    // MARK: - Register Cell
    func register<T: UICollectionViewCell>(_ cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: String(describing: cellType))
    }
    
    // MARK: - Dequeue Cell
    func dequeueReusableCell<T: UICollectionViewCell>(
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T else {
            fatalError("Cannot dequeue cell with identifier \(T.self)")
        }
        return cell
    }
    
    // MARK: - Register Header/Footer Cell
    
    func registerSupplementary<T: UICollectionReusableView>(
        _ viewType: T.Type,
        ofKind kind: String
    ) {
        register(viewType,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: String(describing: viewType))
    }
    
    // MARK: - Dequeue Header/Footer Cell
    func dequeueSupplementary<T: UICollectionReusableView>(
        ofKind kind: String,
        for indexPath: IndexPath
    ) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T else {
            fatalError("Cannot dequeue supplementary view")
        }
        return view
    }
}
