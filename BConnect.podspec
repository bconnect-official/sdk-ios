#
# Be sure to run `pod lib lint BConnect.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    
  s.name             = 'BConnect'
  s.version          = '1.0.0'
  s.summary          = 'iOS SDK for b.connect.'

  s.description      = <<-DESC
                       iOS SDK for b.connect.
                       DESC

  s.homepage         = "https://bconnect.net"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'BConnect' => 'sdk@bconnect.net' }
  s.source           = { :git => 'git@github.com:bconnect-official/sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'BConnect/Classes/**/*'
  
  s.resources = 'BConnect/Assets/*'
  s.resource_bundles = {
    'BConnect' => ['BConnect/Assets/*']
  }
  s.dependency 'AlamofireImage', '~> 4.3'
  s.dependency 'AppAuth', '~> 1.7.3'
  
end
