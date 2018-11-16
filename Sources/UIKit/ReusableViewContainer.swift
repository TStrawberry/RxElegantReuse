//
//  ReusableViewContainer.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/11/1.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit

extension UITableView : IndexedContainer { }

extension UICollectionView: IndexedContainer { }

#if canImport(RxCocoa)

import RxCocoa

extension UITableView : ModelIndexedContainer {
    
    public typealias IndexedType = UITableViewCell
    
    public func model<T>(at indexPath: IndexPath) throws -> T {
        return try rx.model(at: indexPath)
    }
    
}

extension UICollectionView : ModelIndexedContainer {
    
    public typealias IndexedType = UICollectionViewCell
    
    public func model<T>(at indexPath: IndexPath) throws -> T {
        return try rx.model(at: indexPath)
    }
    
}

#endif

