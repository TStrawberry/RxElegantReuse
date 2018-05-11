# RxElegantReuse
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
    soon
    ```

- **Using [Carthage](https://github.com/Carthage/Carthage)**:
    ```
    soon
    ```

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
- Step 2 : Getting a Event through a Swift 4.0 KeyPath, merging it, and using it.
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    ...
    tableView.rx.events(\CustomCell.button.rx.tap)  /// Getting an Event through a KeyPath<ReusableView, ObservableConvertibleType>
        .merge()                                    /// Merging(required) to get an Observable
        .map(...)                                   /// Everything is familiar to you from now on
        .filter(...)
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
