# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'NCNews' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Networking
  pod 'OAuthSwift', '~> 1.2'
  pod 'Alamofire', '~> 4.6'
  pod 'AlamofireImage', '~> 3.3'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.2'

  # Cell Customization
  pod 'TDBadgedCell', '~> 5.2'

  # Promises
  pod 'PromiseKit', '~> 6.0'
  pod 'PromiseKit/Alamofire', '~> 6.0'

  # QA Tools
  pod 'SwiftLint'

  # eventually we'll use this
  #  pod 'SwipeCellKit', '~> 2.0'
  
  target 'NCNewsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NCNewsUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
