
Pod::Spec.new do |s|

  s.name         = "LXRouter"
  s.version      = "0.2.0"
  s.summary      = "LXRouter"
  s.homepage     = "https://github.com/livesxu/LXRouter.git"
  s.license      = "MIT"
  s.author       = { "livesxu" => "livesxu@163.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/livesxu/LXRouter.git", :tag => s.version }
  s.source_files  = "Router"
  s.frameworks    = 'UIKit', 'CoreFoundation'
  s.requires_arc  = true

end