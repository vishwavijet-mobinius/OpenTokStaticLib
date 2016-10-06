Pod::Spec.new do |s|
  s.name         = 'OpenTokStaticLib'
  s.version      = '0.0.1'
  s.summary      = 'OpenTokStaticLib is wrap around for OpenTok SDK.'
  s.author       = { 
			'vishwavijet-mobinius' => 'vishwavijet.nb@mobinius.com' 
		}
  s.source       = { :git => 'https://github.com/vishwavijet-mobinius/OpenTokStaticLib.git', :tag => s.version.to_s}
  s.homepage     = 'https://github.com/vishwavijet-mobinius/OpenTokStaticLib'
  s.license      = 'MIT'
  s.source_files = '*.{h,m}'
  s.platform     = :ios, '9.0'
  s.framework    = 'SystemConfiguration'
  s.requires_arc = true
  s.dependency 'OpenTok'
end
