

platform :ios, '8.0'
use_frameworks!

target :Swiften do

  pod 'SwiftyJSON’, ‘2.3.2’
   pod 'SwiftyJSON’, ‘2.3.2’
  pod 'KeychainSwift', '3.0.16'
  pod 'ObjectMapper’,’1.5.0’
  pod 'RealmSwift’, ‘>=0.99.0’
  pod 'Alamofire' ,’3.5.1’
  pod ‘Realm’,’>=0.99.0’
  pod 'AlamofireObjectMapper’,’3.0.2’
  pod 'AlamofireImage’,’2.5.0’
  
end

target :SwiftenTests do
    
  pod 'SwiftyJSON’, ‘2.3.2’
  pod 'KeychainSwift', '3.0.16'
  pod 'ObjectMapper’,’1.5.0’
  pod 'RealmSwift’, ‘>=0.99.0’
  pod 'Alamofire' ,’3.5.1’
  pod ‘Realm’,’>=0.99.0’
  pod 'AlamofireObjectMapper’,’3.0.2’
  pod 'AlamofireImage’,’2.5.0’
  
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
