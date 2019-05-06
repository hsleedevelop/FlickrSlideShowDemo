install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '10.0'

# ignore all warnings from all pods
inhibit_all_warnings!

def rx_pods
  # RX
  pod 'RxSwift', '~> 4.4.2'
  pod 'RxCocoa', '~> 4.4.2'
  pod 'RxSwiftExt', '~> 3.4.0'
  pod 'RxSwiftUtilities'
end

def network_pods
  pod 'FeedKit'
  pod 'RxReachability'
end

def ui_pods
  pod 'Toast-Swift'
end

def debug_pods
  # debug
  pod 'FLEX',   :configurations => ['Debug']
end

def sca_pods
  pod 'SwiftLint'
end

def shared_pods
    use_frameworks!
    rx_pods
    network_pods
    ui_pods
    debug_pods
    sca_pods
end

target 'FlickrSlideShow' do
    shared_pods
end

target 'FlickrSlideShowTests' do
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = '4.2'
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = swift_version
        end
    end
end
