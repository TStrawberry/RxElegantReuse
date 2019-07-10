//
//  ReusableViewContainer.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/11/1.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit
import RxCocoa

extension UITableView : ModelIndexedContainer {
    
    public typealias Indexed = UITableViewCell
    
    public func model<T>(at indexPath: IndexPath) throws -> T {
        return try rx.model(at: indexPath)
    }
    
}

extension UICollectionView : ModelIndexedContainer {
    
    public typealias Indexed = UICollectionViewCell
    
    public func model<T>(at indexPath: IndexPath) throws -> T {
        return try rx.model(at: indexPath)
    }
    
}
