Pod::Spec.new do |s|
  s.name         = "SPXMasking"
  s.version      = "1.1.1"
  s.summary      = "SPXMasking is category on CALayer that allows you to specify different a corner radius for each corner of a CALayer."
  s.homepage     = "http://shaps.me/blog/calayer-masking/"
  s.license      = 'MIT'
  s.author             = { "Shaps Mohsenin" => "shaps80@me.com" }
  s.social_media_url = "http://twitter.com/shaps"
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/shaps80/SPXMasking.git", :tag => s.version.to_s }
  s.source_files  = 'Pod/Classes', '*.{h,m}'
  s.requires_arc = true
end
