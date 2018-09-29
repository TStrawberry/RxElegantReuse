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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let updateItem = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(updateItemClicked(_:)))
        navigationItem.rightBarButtonItem = updateItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "RxSwift.Resources.total : " + "\(RxSwift.Resources.total)"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell.textLabel?.text = "UITableViewController"
        } else {
            cell.textLabel?.text = "UICollectionViewController"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let tableViewController = TableViewController(style: .plain)
            navigationController?.pushViewController(tableViewController, animated: true)
        } else {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.itemSize = CGSize(width: 200, height: 60)
            flowLayout.headerReferenceSize = CGSize(width: 80, height: 80)
            flowLayout.footerReferenceSize = CGSize(width: 80, height: 80)
            let collectionViewController = CollectionViewController(collectionViewLayout: flowLayout)
            navigationController?.pushViewController(collectionViewController, animated: true)
        }
    }
    
    @objc func updateItemClicked(_ sender: UIBarButtonItem) {
        navigationItem.title = "RxSwift.Resources.total : " + "\(RxSwift.Resources.total)"
    }
    
}


// MARK: - Example of UITableView
class DemoTableViewCellOne: UITableViewCell {
    
    let button: UIButton
    
    #if os(iOS)
    let switcher: UISwitch
    
    let stepper: UIStepper
    
    let slider: UISlider
    
    var errorObservable: Observable<()> {
        return button.rx.tap.take(3)
            .concat(Observable.error(RxError.unknown))
            .asObservable()
    }
    #endif
    
    private let stackView: UIStackView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        button = UIButton()
        button.setTitleColor(UIColor(named: "buttonTitleDefault"), for: .normal)
        button.setTitle("Button", for: .normal)
        button.setTitleColor(UIColor.gray, for: .focused)
        
        #if os(iOS)
        switcher = UISwitch(frame: .zero)
        stepper = UIStepper()
        slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 100
        slider.value = 50
        stackView = UIStackView(arrangedSubviews: [button, switcher, stepper, slider])
        #endif
        
        #if os(tvOS)
        stackView = UIStackView(arrangedSubviews: [button])
        #endif
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        contentView.addSubview(stackView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            ])
        
        #if os(iOS)
        NSLayoutConstraint.activate([
            slider.leftAnchor.constraint(equalTo: slider.superview!.leftAnchor, constant: 20),
            slider.rightAnchor.constraint(equalTo: slider.superview!.rightAnchor, constant: -20)
            ])
        #endif
        
    }
    
    #if os(tvOS)
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return super.preferredFocusEnvironments + [button]
    }
    #endif
}

class TableViewHeaderView: UITableViewHeaderFooterView {
    
    let button: UIButton = UIButton()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        button.setTitleColor(UIColor(named: "buttonTitleDefault"), for: .normal)
        button.setTitle("Button in header", for: .normal)
        button.setTitleColor(UIColor.gray, for: .focused)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    #if os(tvOS)
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [button]
    }
    #endif
    
}


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
















// MARK: - Example of UITCollectionView
class DemoButtonCollectionViewCell: UICollectionViewCell {
    
    let button: UIButton
    
    override init(frame: CGRect) {
        button = UIButton()
        button.setTitleColor(UIColor(named: "buttonTitleDefault"), for: .normal)
        button.setTitle("Button in cell", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.gray, for: .focused)
        
        super.init(frame: frame)
        
        contentView.addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
    
    #if os(tvOS)
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [button]
    }
    override var canBecomeFocused: Bool {
        return false
    }
    #endif
}


#if os(iOS)
class DemoStepperCollectionViewCell: UICollectionViewCell {
    
    let stepper: UIStepper = UIStepper()

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        stepper.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stepper)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            stepper.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stepper.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
    }
}
#endif



class CollectionViewHeaderView: UICollectionReusableView {
    
    var section: Int? = nil
    
    let button: UIButton
    
    override init(frame: CGRect) {
        button = UIButton()
        button.setTitleColor(UIColor(named: "buttonTitleDefault"), for: .normal)
        button.setTitleColor(UIColor.gray, for: .focused)
        button.setTitle("Button in header", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frame)
        
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    #if os(tvOS)
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [button]
    }

    override var canBecomeFocused: Bool {
        return false
    }
    #endif
    
}

class CollectionViewFooterBaseView: UICollectionReusableView {
    
    #if os(iOS)
    let switcher: UISwitch = UISwitch()
    #endif
    
    #if os(tvOS)
    let button: UIButton = UIButton()
    #endif
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        #if os(iOS)
        addSubview(switcher)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        #endif
        
        #if os(tvOS)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Button in footer", for: .normal)
        button.setTitleColor(UIColor(named: "buttonTitleDefault"), for: .normal)
        button.setTitleColor(UIColor.gray, for: .focused)
        #endif
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        #if os(iOS)
        let view = switcher
        #endif
        
        #if os(tvOS)
        let view = button
        #endif
        
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    
    #if os(tvOS)
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [button]
    }

    override var canBecomeFocused: Bool {
        return false
    }
    #endif
    
}

class CollectionViewFooterView: CollectionViewFooterBaseView {
    
}


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
        collectionView?.register(CollectionViewHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeaderView")
        collectionView?.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CollectionViewFooterView")
        
        
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

            if kind == UICollectionElementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeaderView", for: indexPath)
                    .managed(by: collectionView)
                (header as? CollectionViewHeaderView)?.section = indexPath.section
                return header
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

