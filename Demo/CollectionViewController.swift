//
//  CollectionViewController.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/11/19.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxElegantReuse


class CollectionViewController: UICollectionViewController {
    
    enum Controls: String {
        case button = "DemoButtonCollectionViewCell"
        #if os(iOS)
        case stepper = "DemoStepperCollectionViewCell"
        #endif
    }
    
    let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
        
        collectionView?.rx.setDelegate(self).disposed(by: bag)
        collectionView?.backgroundColor = .white
        
        collectionView?.register(DemoButtonCollectionViewCell.self, forCellWithReuseIdentifier: "DemoButtonCollectionViewCell")
        #if os(iOS)
        collectionView?.register(DemoStepperCollectionViewCell.self, forCellWithReuseIdentifier: "DemoStepperCollectionViewCell")
        #endif
        collectionView?.register(CollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeaderView")
        collectionView?.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CollectionViewFooterView")
        
        
        #if os(tvOS)
        collectionView?.rx.events(\CollectionViewHeaderView.button.rx.primaryAction)
            .with({ (collectionView, headerView, event) -> ControlEvent<Int?> in
                return ControlEvent(events: event.map { headerView.section })
            })
            .subscribe(onNext: { (section) in
                print(section)
            })
            .disposed(by: bag)
        
        collectionView?.rx
            .events(\DemoButtonCollectionViewCell.button.rx.primaryAction)
            .subscribe({ (_) in
                print("button")
            })
            .disposed(by: bag)
        #endif
        
        
        #if os(iOS)
        let section = SectionModel<String, Controls>(model: "Section Model", items: [.button, .stepper, .stepper, .button])
        #endif
        
        #if os(tvOS)
        let section = SectionModel<String, Controls>(model: "Section Model", items: [.button, .button, .button, .button, .button, .button])
        #endif
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Controls>> (configureCell: {
            (_, collectionView, indexPath, control) in
            collectionView.dequeueReusableCell(withReuseIdentifier: control.rawValue, for: indexPath)
                .managed(by: collectionView)
        })
        
        dataSource.configureSupplementaryView = {
            (_, collectionView, kind, indexPath) in
            
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionViewHeaderView", for: indexPath)
                    .managed(by: collectionView)
                (header as? CollectionViewHeaderView)?.section = indexPath.section
                return header
            } else if kind == UICollectionView.elementKindSectionFooter {
                return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "CollectionViewFooterView", for: indexPath)
                    .managed(by: collectionView)
            } else {
                fatalError()
            }
        }
        
        Observable.just(Array(repeating: section, count: 10))
            .bind(to: collectionView!.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        #if os(iOS)
        collectionView?.rx
            .events(\DemoStepperCollectionViewCell.stepper.rx.value.changed)
            .subscribe({ (_) in
                print("stepper")
            })
            .disposed(by: bag)
        
        collectionView?.rx.events(\CollectionViewHeaderView.button.rx.tap)
            .with({ (collectionView, headerView, event) -> ControlEvent<Int?> in
                return ControlEvent(events: event.map { headerView.section })
            })
            .subscribe(onNext: { (section) in
                print(section)
            })
            .disposed(by: bag)
        
        collectionView?.rx.events(\CollectionViewFooterView.switcher.rx.isOn.changed)
            .subscribe(onNext: { (_) in
                print("Switch in footer switched")
            })
            .disposed(by: bag)
        #endif
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.navigationItem.title = "RxSwift.Resources.total: \(RxSwift.Resources.total)"
        }
    }
    
}
