//
//  Views.swift
//  RxElegantReuse
//
//  Created by TStrawberry on 2018/11/19.
//  Copyright © 2018 TStrawberry. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - UITableView
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





// MARK: - UICollectionView
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

