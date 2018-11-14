Pod::Spec.new do |s|
  s.name             = "LaserFloatingTextField"
  s.version          = "1.0.0"
  s.summary          = "Implementation of Google's 'Floating labels' of Material design."
  s.homepage         = "https://github.com/LaserSrl/LaserFloatingTextField"
  s.license          = 'MIT'
  s.author           = { "Patrick Laser" => "patrick.negretto@laser-group.com" }
  s.source           = { :git => "https://github.com/LaserSrl/LaserFloatingTextField.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.dependency 'PureLayout', '~>3.0'
  s.source_files = 'EGFloatingTextField/EGFloatingTextField/*.swift'
  s.resource = 'EGFloatingTextField/EGFloatingTextField/**/*.{lproj}'
end

