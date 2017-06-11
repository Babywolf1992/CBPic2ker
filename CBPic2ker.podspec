Pod::Spec.new do |s|
  s.name             = 'CBPic2ker'
  s.version          = '1.0.0'
  s.summary          = 'A cool photo selecter, will blow your mind.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/cbangchen/CBPic2ker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cbangchen' => 'cbangchen007@gmail.com' }
  s.source           = { :git => 'https://github.com/cbangchen/CBPic2ker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'CBPic2ker/Classes/**/*'
  s.public_header_files = 'CBPic2ker/Classes/**/*.h'
  s.resource = "CBPic2ker/Resources/**/*.bundle"

  s.frameworks = 'UIKit', 'Foundation'
end
