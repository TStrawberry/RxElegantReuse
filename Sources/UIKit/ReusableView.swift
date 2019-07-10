//
//  ReusableView.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/11/1.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit
import RxSwift

extension UITableViewCell : IndexedType {
    public typealias Container = UITableView
    public typealias BaseReusable = UITableViewCell
    public typealias Indexed = UITableViewCell
}

extension UITableViewHeaderFooterView : ReusableType {
    public typealias Container = UITableView
    public typealias BaseReusable = UITableViewHeaderFooterView
}

extension UICollectionReusableView : ReusableType {
    public typealias Container = UICollectionView
    public typealias BaseReusable = UICollectionReusableView
}

extension UICollectionViewCell : IndexedType {
    public typealias Indexed = UICollectionViewCell
}

public typealias ReusableView = UIView & ReusableType
public typealias IndexedView = ReusableView & IndexedType

