Pod::Spec.new do |s|
  s.name             = 'HelloCocoaPods'
  s.version          = '0.1.0'
  s.summary          = 'A short description of HelloCocoaPods.'
  s.description      = 'A longer description of HelloCocoaPods for Artifactory.'
  s.homepage         = 'https://github.com/slash-l/jpd-project/jpd-dev/cocoapods/HelloCocoaPods'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jingyi' => 'jingyi@example.com' }
  
  # 指向你的 Artifactory 压缩包地址（发布后更新）
  s.source           = { :http => "https://soleng.jfrog.io/artifactory/slash-cocoapods-dev-local/HelloCocoaPods/0.1.0/HelloCocoaPods.tar.gz" }

  s.ios.deployment_target = '13.0'
  s.source_files = 'HelloCocoaPods/**/*.{swift,h,m}'
  s.swift_version = '5.0'

  # 如果你的包还依赖其他包，也可以写在这里
  s.dependency 'Alamofire', '~> 5.8'
end