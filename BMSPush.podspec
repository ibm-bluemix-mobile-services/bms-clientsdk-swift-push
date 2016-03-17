Pod::Spec.new do |s|

  s.name         = 'BMSPush'
  s.version      = '0.1.03'
  s.summary      = 'The core component of the Swift client Push SDK for IBM Bluemix Mobile Services'
  s.homepage     = 'https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-push'
  s.license      = 'Apache License, Version 2.0'
  s.authors      = { 'IBM Bluemix Services Mobile SDK' => 'mobilsdk@us.ibm.com' }

  s.source       = { :git => 'https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-push.git', :tag => "v#{s.version}" }
  s.source_files = 'Source/*.swift'

  s.requires_arc = true

  s.dependency 'BMSCore'

  s.ios.deployment_target = '8.0'
  
end
