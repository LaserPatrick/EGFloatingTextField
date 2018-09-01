Pod::Spec.new do |s|
  s.name             = "EGFloatingTextField"
  s.version          = "0.1.7"
  s.summary          = "Implementation of Google's 'Floating labels' of Material design."
  s.homepage         = "https://github.com/LaserPatrick/EGFloatingTextField"
  s.license          = 'MIT'
  s.author           = { "Enis Gayretli" => "enisgayretli@gmail.com" }
  s.source           = { :git => "https://github.com/LaserPatrick/EGFloatingTextField.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/enisgayretli'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.dependency 'PureLayout', '~>3.0'
  s.source_files = 'EGFloatingTextField/EGFloatingTextField/*.swift'
  s.resource = 'EGFloatingTextField/EGFloatingTextField/**/*.{lproj}'
end

