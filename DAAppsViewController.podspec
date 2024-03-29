Pod::Spec.new do |s|
  s.name     = 'DAAppsViewController'
  s.version  = '2.0.0'
  s.platform = :ios, '12.0'
  s.license  = 'MIT'
  s.summary  = 'DAAppsViewController is a simple way of displaying apps from the App Store in an aesthetically similar manner.'
  s.homepage = 'https://github.com/danielamitay/DAAppsViewController'
  s.author   = { 'Daniel Amitay' => 'hello@danielamitay.com' }
  s.source   = { :git => 'https://github.com/danielamitay/DAAppsViewController.git', :tag => s.version.to_s }
  s.description = 'DAAppsViewController is a simple way of displaying apps from the App Store in an aesthetically similar manner. The user is able to view each app’s App Store page by launching an instance of SKStoreProductViewController. Particularly useful for showing an app developer’s other apps.'
  s.public_header_files = 'DAAppsViewController/DAAppsViewController.h'
  s.source_files = 'DAAppsViewController/*.{h,m}'
  s.frameworks 	 = 'StoreKit'
  s.requires_arc = true
end
