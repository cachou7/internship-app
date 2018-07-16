# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'


  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  target 'PLC' do
    pod 'Firebase'
    pod 'FirebaseDatabase'
    pod 'Firebase/Auth'
    pod 'Firebase/Storage'
    pod 'NavigationDropdownMenu', '~> 4.0.0'
    pod 'FSCalendar'
  end

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end
  # Pods for PLC

  target 'PLCTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PLCUITests' do
    inherit! :search_paths
    # Pods for testing
  end
