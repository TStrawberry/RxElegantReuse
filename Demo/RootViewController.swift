//
//  RootViewController.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/11/19.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit
import RxSwift

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
