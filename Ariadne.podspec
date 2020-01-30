Pod::Spec.new do |s|
  s.name         = "Ariadne"
  s.version      = "0.6.0"
  s.summary      = "Elegant and extensible routing framework in Swift."
  s.homepage     = "https://github.com/DenTelezhkin/Ariadne"
  s.license  = 'MIT'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin.oss@gmail.com' }
  s.social_media_url = 'https://twitter.com/DenTelezhkin'
  s.requires_arc = true
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '3.0'
  s.source   = { :git => 'https://github.com/DenTelezhkin/Ariadne.git', :tag => s.version.to_s }
  s.source_files  = "Source/Ariadne/*.{swift}"
  s.swift_versions = ['4.2', '5.0']
  s.ios.frameworks = "Foundation", "UIKit"
  s.tvos.frameworks = "Foundation", "UIKit"
  s.osx.frameworks = "Foundation", "AppKit"
  s.watchos.frameworks = "Foundation", "WatchKit"
end
