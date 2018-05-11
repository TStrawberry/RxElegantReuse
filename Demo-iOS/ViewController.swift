//
//  ViewController.swift
//  Demo-iOS
//
//  Created by TStrawberry on 2018/5/9.
//  Copyright © 2018年 TStrawberry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Differentiator
import RxDataSources
import RxElegantReuse

class RootViewController: UITableViewController {
    @IBAction func updateItemClicked(_ sender: UIBarButtonItem) {
        navigationItem.title = "RxSwift.Resources.total : " + "\(RxSwift.Resources.total)"
    }
}

// MARK: - Example of UITableView
class DemoTableViewCellOne: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var switcher: UISwitch!
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var slider: UISlider!
}

class TableViewHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var button: UIButton!
    
}

class TableViewController: UITableViewController {
    
    let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.rx.setDelegate(self).disposed(by: bag)
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "Header")
        
        let section = SectionModel<String, String>(model: "Section Model", items: ["Cell Model"])

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>.init(configureCell: {
            (_, tableView, _, _) in
            
            return tableView.dequeueReusableCell(withIdentifier:"DemoTableViewCellOne")!.managed(by: tableView)
        })
        
        
        let sections = Array(repeating: section, count: 10)
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.events(\TableViewHeaderView.button.rx.tap)
            .merge()
            .subscribe(onNext: { (_) in
                print("header")
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.button.rx.tap)
            .mergeWithIndexPath { $1 }
            .subscribe(onNext: { (indexPath) in
                print(indexPath)
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.slider.rx.value.changed)
            .merge()
            .subscribe(onNext: { (value) in
                print(value)
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.switcher.rx.isOn.changed)
            .merge()
            .subscribe(onNext: { (isOn) in
                print(isOn)
            })
            .disposed(by: bag)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.navigationItem.title = "RxSwift.Resources.total: \(RxSwift.Resources.total)"
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header")?.managed(by: tableView)
    }
    
}







// MARK: - Example of UITCollectionView
class DemoButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
}

class DemoStepperCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var stepper: UIStepper!
}

class CollectionViewHeaderView: UICollectionReusableView {
    @IBOutlet weak var button: UIButton!
}

class CollectionViewFooterBaseView: UICollectionReusableView {
    
    let switcher: UISwitch = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(switcher)
        switcher.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            switcher.centerXAnchor.constraint(equalTo: centerXAnchor),
            switcher.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
}

class CollectionViewFooterView: CollectionViewFooterBaseView {
    
}


class CollectionViewController: UICollectionViewController {
    
    enum Controls: String {
        case button = "DemoButtonCollectionViewCell"
        case stepper = "DemoStepperCollectionViewCell"
    }
    
    let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
        
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: 80, height: 80)
        layout.footerReferenceSize = CGSize(width: 80, height: 80)
        
        
        collectionView?.register(UINib(nibName: "CollectionViewHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeaderView")
        collectionView?.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionViewFooterView")
        
        collectionView?.rx
            .events(\DemoButtonCollectionViewCell.button.rx.tap)
            .merge()
            .subscribe({ (event) in
                print("tapped")
            })
            .disposed(by: bag)
        
        let section = SectionModel<String, Controls>(model: "Section Model", items: [.button, .stepper, .stepper, .button])
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Controls>>.init (configureCell: {
            (_, collectionView, indexPath, control) in
            collectionView.dequeueReusableCell(withReuseIdentifier: control.rawValue, for: indexPath)
                .managed(by: collectionView)
        })
        
        
        dataSource.configureSupplementaryView = {
            (_, collectionView, kind, indexPath) in
            
            if kind == UICollectionElementKindSectionHeader {
                return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeaderView", for: indexPath)
                    .managed(by: collectionView)
            } else if kind == UICollectionElementKindSectionFooter {
                return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionViewFooterView", for: indexPath)
                    .managed(by: collectionView)
            } else {
                fatalError()
            }
        }
        
        Observable.just(Array(repeating: section, count: 10))
            .bind(to: collectionView!.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        collectionView?.rx
            .events(\DemoStepperCollectionViewCell.stepper.rx.value.changed)
            .merge()
            .subscribe({ (_) in
                print("stepper")
            })
            .disposed(by: bag)
        
        collectionView?.rx.events(\CollectionViewHeaderView.button.rx.tap)
            .merge()
            .subscribe(onNext: { (_) in
                print("Button in header tapped")
            })
            .disposed(by: bag)
        
        collectionView?.rx.events(\CollectionViewFooterView.switcher.rx.isOn.changed)
            .merge()
            .subscribe(onNext: { (_) in
                print("Switch in footer switched")
            })
            .disposed(by: bag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.navigationItem.title = "RxSwift.Resources.total: \(RxSwift.Resources.total)"
        }
    }
    
}
