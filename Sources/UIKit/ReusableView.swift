//
//  ReusableView.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/11/1.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit
import RxSwift

extension UITableViewCell : Indexed {
    public typealias BaseReusableType = UITableViewCell
    public typealias IndexedType = UITableViewCell
}

extension UITableViewHeaderFooterView : Reusable {
    public typealias BaseReusableType = UITableViewHeaderFooterView
}

extension UICollectionReusableView : Reusable {
    public typealias BaseReusableType = UICollectionReusableView
}

extension UICollectionViewCell : Indexed {
    public typealias IndexedType = UICollectionViewCell
}

public typealias ReusableView = UIView & Reusable
public typealias IndexedView = ReusableView & Indexed

