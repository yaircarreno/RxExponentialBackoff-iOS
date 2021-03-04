# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def rxswift
  pod 'RxSwift', '6.0.0'
  pod 'RxCocoa', '6.0.0'
end

def testing_rxswift
  pod 'RxBlocking', '6.0.0'
  pod 'RxTest', '6.0.0'
end

target 'RxExponentialBackoff' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  rxswift

  target 'RxExponentialBackoffTests' do
    inherit! :search_paths
    testing_rxswift
  end

  target 'RxExponentialBackoffUITests' do
    inherit! :search_paths
    testing_rxswift
  end

end
