#
# Be sure to run `pod lib lint Nexum.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'Nexum'
    s.version          = '1.0'
    s.summary          = "Modern, Lightweight Reachability for iOS Apps in Objective-C"
    s.description      = "Updated Reachability for iOS Apps in Objective-C, based on Apple's Reachability, along with some other network utilities"
    s.homepage         = 'https://github.com/vsanthanam/Nexum'
    s.license          = { :type => 'Copyright', :text => 'MIT' }
    s.author           = { 'Varun Santhanam' => 'talkto@vsanthanam.com' }
    s.source           = { :git => 'https://github.com/vsanthanam/Nexum.git', :tag => s.version.to_s }
    s.ios.deployment_target = '9.0'
    s.source_files = 'Nexum/*.{h,m}'
    s.public_header_files = 'Nexum/*.h'
    s.module_map = 'Nexum/Supporting/module.modulemap'
    s.documentation_url = 'https://code.vsanthanam.com/Nexum/Documentation/index.html'
    s.static_framework = true
end
