Pod::Spec.new do |s|

  s.name         = 'BMSPush'

  s.version      = '3.4.2'

  s.summary      = 'Swift client side Push SDK for IBM Bluemix Push notifications services'
  s.homepage     = 'https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-push'
  s.license      = 'Apache License, Version 2.0'
  s.authors      = { 'IBM Bluemix Services Mobile SDK' => 'mobilsdk@us.ibm.com' }
  s.source       = { :git => 'https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-push.git', :tag => s.version }
  s.source_files = 'Source/**/*.swift'


  s.dependency 'BMSCore', '~> 2.0'
  s.ios.deployment_target = '8.0'

  s.requires_arc = true

end
