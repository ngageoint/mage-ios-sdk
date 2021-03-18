Pod::Spec.new do |s|
  s.name             = "mage-ios-sdk"
  s.version          = "3.1.2"
  s.summary          = "iOS SDK for MAGE"
  s.description      = <<-DESC
                       iOS SDK for MAGE, assist with:

                       * MAGE authentication.
                       * MAGE observations CRUD operations
                       * MAGE location services
                       DESC
  s.homepage         = "https://www.nga.mil"
  s.license          = 'Apace 2.0'
  s.author           = { "NGA" => "winewman@caci.com" }
  s.source           = { :git => "https://github.com/ngageoint/mage-ios-sdk.git", :tag => s.version.to_s }

  s.platform         = :ios, '13.0'
  s.ios.deployment_target = '13.0'
  s.requires_arc = true

  s.source_files = 'MAGE/**/*.{h,m}'
  s.prefix_header_file = 'MAGE/mage-ios-sdk-Prefix.pch'

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.resource_bundle = { 'MageSDK' => ['MAGE/**/*.plist'] }
  s.resources = ['MAGE/**/*.xcdatamodeld', 'MAGE/**/*.xcmappingmodel']
  s.static_framework=true
  s.frameworks = 'Foundation'
  s.dependency 'AFNetworking', '~> 4.0.1'
  s.dependency 'DateTools', '~> 2.0.0'
  s.dependency 'MagicalRecord', '~> 2.3.2'
  s.dependency 'geopackage-ios', '~> 5.0.0'
  s.dependency 'SSZipArchive', '~> 2.2.2'
end
