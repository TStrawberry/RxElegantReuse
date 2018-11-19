//
//  TableViewController.swift
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


class TableViewController: UITableViewController {
    
    let bag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.rx.setDelegate(self).disposed(by: bag)
        tableView.register(TableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(DemoTableViewCellOne.self, forCellReuseIdentifier: "DemoTableViewCellOne")
        
        let section = SectionModel<String, String>(model: "Section Model", items: ["Cell Model", "Cell Model 1"])
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: {
            (_, tableView, _, _) in
            let cell = tableView.dequeueReusableCell(withIdentifier:"DemoTableViewCellOne")!
                .managed(by: tableView)
            return cell
        })
        
        let sections = Array(repeating: section, count: 10)
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        #if os(tvOS)
        tableView.rx.events(\DemoTableViewCellOne.button.rx.primaryAction)
            .withIndexPath { $1 }
            .subscribe(onNext: { (indexPath) in
                print(indexPath)
            })
            .disposed(by: bag)
        
        tableView.rx.events(\TableViewHeaderView.button.rx.primaryAction)
            .subscribe(onNext: { (_) in
                print("Button in header")
            })
            .disposed(by: bag)
        #endif
        
        #if os(iOS)
        tableView.rx.events(\TableViewHeaderView.button.rx.tap)
            .subscribe(onNext: { (_) in
                print("header")
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.stepper.rx.value.changed)
            .withIndexPath { ($0, $1) }
            .subscribe(onNext: { (values) in
                print(values)
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.button.rx.tap)
            .withIndexPath { $1 }
            .subscribe(onNext: { (indexPath) in
                print(indexPath)
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.slider.rx.value.changed)
            .withModel(with: String.self, { $1 })
            .subscribe(onNext: { (value) in
                print(value)
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.errorObservable)
            .catchEventsError({ (_) -> Observable<()> in
                Observable.empty()
            })
            .subscribe(onNext: { (value) in
                print(value)
            })
            .disposed(by: bag)
        
        tableView.rx.events(\DemoTableViewCellOne.switcher.rx.isOn.changed)
            .subscribe(onNext: { (isOn) in
                print(isOn)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView")?
            .managed(by: tableView)
    }
    
}
