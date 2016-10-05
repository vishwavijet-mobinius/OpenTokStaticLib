Pod::Spec.new do |s|
  s.name         = 'OpenTokStaticLib'
  s.version      = '0.0.1'
  s.summary      = 'OpenTokStaticLib is wrap around for OpenTok SDK.'
  s.author       = { 
			'vishwavijet-mobinius' => 'vishwavijet.nb@mobinius.com' 
		}
  s.source       = ''
  s.homepage     = 'https://github.com/OpenTokStaticLib'
  s.license      = 'MIT'
  s.platform     = :ios, '9.0'
  s.source_files = 'OpenTokStaticLib/*.{h,m}'
  s.framework    = 'SystemConfiguration'
  s.requires_arc = true
  s.dependency 'OpenTok'
end
