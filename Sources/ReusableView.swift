//
//  ReusableView.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/4/4.
//

import UIKit
import RxSwift

public protocol Reusable: NSObjectProtocol {
    associatedtype BaseReusableViewType : UIView
}

public protocol Indexed: Reusable {
    associatedtype IndexedViewType : UIView
}

extension UITableViewCell : Indexed {
    public typealias BaseReusableViewType = UITableViewCell
    public typealias IndexedViewType = UITableViewCell
}

extension UITableViewHeaderFooterView : Reusable {
    public typealias BaseReusableViewType = UITableViewHeaderFooterView
}

extension UICollectionReusableView : Reusable {
    public typealias BaseReusableViewType = UICollectionReusableView
}

extension UICollectionViewCell : Indexed {
    public typealias IndexedViewType = UICollectionViewCell
}

public typealias ReusableView = UIView & Reusable
public typealias IndexedView = ReusableView & Indexed

public extension Reusable where Self : UIView {
    @discardableResult
    func managed<T : UIScrollView & ReusableViewContainer>(by container: T?) -> Self {
        _ = MainScheduler.asyncInstance
            .schedule((container, self)) { (params) -> Disposable in
                params.0?.add(params.1)
                return Disposables.create()
            }
        return self
    }
}
