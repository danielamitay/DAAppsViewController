Pod::Spec.new do |s|
  s.name     = 'DAAppsViewControllerPortraitLandscape'
  s.version  = '1.4.0'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'DAAppsViewController is a simple way of displaying apps from the App Store in an aesthetically similar manner. This version adds landscape and localization support.'
  s.homepage = 'https://github.com/lunarbase/DAAppsViewController-PortraitLandscape'
  s.author   = { 'Lunarbase' => '' }
  s.source   = { :git => 'https://github.com/lunarbase/DAAppsViewController-PortraitLandscape.git', :tag => s.version.to_s }
  s.description = 'DAAppsViewController is a simple way of displaying apps from the App Store in an aesthetically similar manner.  This version adds landscape and localization support. The user is able to view each app’s App Store page by launching an instance of SKStoreProductViewController. Particularly useful for showing an app developer’s other apps.'
  s.source_files = 'DAAppsViewController-PortraitLandscape/*.{h,m}'
  s.resources 	 = 'DAAppsViewController-PortraitLandscape/DAAppsViewController.bundle'
  s.frameworks 	 = 'StoreKit'
  s.requires_arc = true
end
