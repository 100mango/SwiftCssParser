#
# Be sure to run `pod lib lint SwiftCssParser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftCssParser'
  s.version          = '0.1.0'
  s.summary          = 'A Powerful, Extensible CSS Parser written in pure Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Powerful, Extensible CSS Parser written in pure Swift.
                       DESC

  s.homepage         = 'https://github.com/100mango/SwiftCssParser'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '100mango' => '' }
  s.source           = { :git => 'https://github.com/100mango/SwiftCssParser.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/100_mango'

  s.source_files = [
    'SwiftCssParser/CssLexer.swift',
    'SwiftCssParser/CssParser.swift',
    'SwiftCssParser/SwiftCSS.swift',
    'SwiftCssParser/SwiftCssTheme.swift',
    'SwiftCssParser/SwiftDeviceCss.swift',
    'SwiftCssParser/UIColorExtension.swift',
  ]

  #s.frameworks = 'UIKit'
  s.ios.framework = 'UIKit'
  s.ios.deployment_target = '9.0'

  # Swift v4 fix
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
