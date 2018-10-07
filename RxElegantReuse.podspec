Pod::Spec.new do |s|
  s.name             = "RxElegantReuse"
  s.version          = "4.2"
  s.summary          = "RxCocoa reuse extensions"
  s.description      = <<-DESC
An elegant and RxSwift-based way to observe events inside of reusable views like UITableViewCell, UICollectionViewCell.
For keeping same major version number with Swift and RxSwift, there is no 1.0, 2.0 and 3.0.
                        DESC
  s.homepage         = "https://github.com/TStrawberry/RxElegantReuse"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "TStrawberry" => "me@tstrawberry.com" }
  s.source           = { :git => "https://github.com/TStrawberry/RxElegantReuse.git", :tag => s.version.to_s }

  s.requires_arc     = true
  s.swift_version    = "4.0"

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Sources/**/*.swift'

  s.frameworks   = "UIKit"

  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'RxCocoa', '~> 4.0'

end