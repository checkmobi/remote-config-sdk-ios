#
# Be sure to run `pod lib lint CheckMobiSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CheckMobiSDK'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CheckMobiSDK.'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/checkmobi/remote-config-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'checkmobi' => 'support@checkmobi.com' }
  s.source           = { :git => 'https://github.com/checkmobi/remote-config-sdk-ios', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'CheckMobiSDK/Classes/**/*'
  
  s.resource_bundles = {
    'CheckMobiSDK' => ['CheckMobiSDK/Classes/Views/*.storyboard']
  }
  s.resources = 'CheckMobiSDK/**/*.{,xcassets}'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'Moya'
  s.dependency 'Moya-ObjectMapper'
  s.dependency 'ObjectMapper'
  s.dependency 'AlamofireImage'
  s.dependency 'KAPinField'
end
