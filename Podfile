# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'PostalCode' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  pod 'Google-Mobile-Ads-SDK'

  # Pods for PostalCode

  target 'PostalCodeTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end