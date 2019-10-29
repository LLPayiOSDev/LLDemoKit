#
# Be sure to run `pod lib lint LLDemoKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LLDemoKit'
  s.version          = '1.0.1'
  s.summary          = '给 LianLian Pay SDK Demo 使用的工具合集.'
  s.description      = <<-DESC
  LLDemoKit是一个给连连支付SDKdemo使用的工具合集， 包括demo的构建， 环境的切换以及自定义等
                       DESC
  s.homepage         = 'https://github.com/LLPayiOSDev/LLDemoKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LLPayiOSDev' => 'iosdev@lianlianpay.com' }
  s.source           = { :git => 'https://github.com/LLPayiOSDev/LLDemoKit.git', :tag => s.version.to_s }
  s.platform         = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true
  s.source_files     = 'LLDemoKit/Classes/**/*'
  s.resource = 'LLDemoKit/Assets/LLDemoResources.bundle'
  s.public_header_files = 'LLDemoKit/**/*.h'
  s.dependency 'SVProgressHUD'
  
end
