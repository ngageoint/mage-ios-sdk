source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

inhibit_all_warnings!

target 'mage-ios-sdk' do
  pod "AFNetworking", "~> 4.0.1"
  pod "DateTools", "~> 2.0.0"
  pod "MagicalRecord", "~> 2.3.2"
  pod 'geopackage-ios', '~> 5.0.0'
  pod 'SSZipArchive', '~> 2.2.2'
end

target :"mage-ios-sdkTests" do
  pod 'OHHTTPStubs', "~> 3.1.0"
  pod 'TRVSMonitor', "~> 0.0.3"
end

post_install do |installer|
     installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
            if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
            end
         end
     end
  end
