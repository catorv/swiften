platform :ios, '8.0'
use_frameworks!

target :Swiften do
  pod 'Alamofire', '~> 4.3'
  pod 'AlamofireImage', '~> 3.2'
  pod 'AlamofireObjectMapper', '~> 4.0'
  pod 'KeychainSwift', '~> 7.0'
  pod 'ObjectMapper', '~> 2.2'
  pod 'ReachabilitySwift', '~> 3'
  pod 'RealmSwift', '~> 2.4'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'Toast-Swift', '~> 2.0.0'
end

target :SwiftenTests do
  pod 'Alamofire', '~> 4.3'
  pod 'AlamofireImage', '~> 3.2'
  pod 'AlamofireObjectMapper', '~> 4.0'
  pod 'KeychainSwift', '~> 7.0'
  pod 'ObjectMapper', '~> 2.2'
  pod 'ReachabilitySwift', '~> 3'
  pod 'RealmSwift', '~> 2.4'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'Toast-Swift', '~> 2.0.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
