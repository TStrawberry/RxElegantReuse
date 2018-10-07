# RxElegantReuse

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxElegantReuse.svg)](https://img.shields.io/cocoapods/v/RxElegantReuse.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/RxElegantReuse.svg?style=flat)](https://github.com/TStrawberry/RxElegantReuse)



An elegant and [RxSwift](https://github.com/ReactiveX/RxSwift)-based way to observe events inside of reusable views like UITableViewCell, UICollectionViewCell.

## Why
Did you feel a little ungainly when you observe an Observable which comes from a UITableViewCell? You maybe have to complete some work like this:
```swift

/// CustomCell.swift
class CustomCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    
    var bag: DisposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
}

/// CustomViewController.swift
class CustomTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data.bind(to: tableView.rx.items(cellIdentifier: "identifier", cellType: CustomCell.self), curriedArgument: {
            (index, data, cell) in
            ...
            cell.button.rx.tap
                .subscribe({ (event) in
                    /// Addd some code
                })
                .disposed(by: cell.bag) 
            ...
        })   
    }
}

```
As you can see, we observe all the Observables in the curriedArgument closure.
Or we can make `cell.button.rx.tap` binding to a Observer outside of the curriedArgument closure, with more code.
There maybe other ways,but no essential difference.So let's move to RxElegantReuse.


## Dependencies

- [RxSwift](https://github.com/ReactiveX/RxSwift) (~> 4.0.0)
- [RxCocoa](https://github.com/ReactiveX/RxSwift) (~> 4.0.0)

## Requirements

- Swift 4
- iOS 8+


## Installation
- **Using [CocoaPods](https://cocoapods.org)**:
    ```ruby
    pod 'RxElegantReuse', '~> 4.2'
    ```

- **Using [Carthage](https://github.com/Carthage/Carthage)**:

    ```
    github "TStrawberry/RxElegantReuse" ~> 4.2
    ```



**For keeping same major version number with Swift and RxSwift, there is no 1.0, 2.0 and 3.0.**
​    

## Usage

RxElegantReuse provide only several API for this specific scene.
- Step 1 : Making the reusable view managed by it's container(UITableView/UiCollectionView).
```swift
data.bind(to: tableView.rx.items(cellIdentifier: "identifier", cellType: CustomCell.self), curriedArgument: {
  [unowned tableView]
    (index, data, cell) in
    ...
    cell.managed(by: tableView)
    ...
}) 
```
- Step 2 : Getting an Events instance through a Swift 4.0 KeyPath and it is an observable sequence.
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    ...
    tableView.rx.events(\CustomCell.button.rx.tap)
        .subscribe(onNext: { (values) in            
            /// Add some code
        })
        .disposed(by: bag)  
    ...
}

```
**Several extra  APIs for customization and convenience are waiting for your try.**

## License
RxElegantReuse is under MIT license.

