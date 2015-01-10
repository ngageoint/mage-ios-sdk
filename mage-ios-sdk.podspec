Pod::Spec.new do |s|
  s.name             = "mage-ios-sdk"
  s.version          = "0.0.2"
  s.summary          = "iOS SDK for MAGE"
  s.description      = <<-DESC
                       iOS SDK for MAGE, assist with:

                       * MAGE authentication.
                       * MAGE observations CRUD operations
                       * MAGE location services
                       DESC
  s.homepage         = "https://www.nga.mil"
  s.license          = 'DOD'
  s.author           = { "NGA" => "newmanw@bit-sys.com" }
  s.source           = { :git => "https://git.***REMOVED***/mage/mage-ios-sdk.git", :tag => s.version.to_s }

  s.platform         = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'MAGE/**/*.{h,m}'
  s.prefix_header_file = 'MAGE/mage-ios-sdk-Prefix.pch'

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.resource_bundle = { 'MageSDK' => ['MAGE/**/*.plist'] }
  s.resources = ['MAGE/**/*.xcdatamodeld']
  s.frameworks = 'Foundation'
  s.dependency 'AFNetworking', '~> 2.3.1'
  s.dependency 'DateTools', '~> 1.3.0'
#  s.dependency 'MagicalRecord', '~> 2.3.0'
  s.dependency 'objective-zip', '~> 0.8.3'
end
