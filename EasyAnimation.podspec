Pod::Spec.new do |s|
  s.name             = "EasyAnimation"
  s.version          = "0.6.4"
  s.summary          = "A Swift library to take the power of UIView.animateWithDuration(_:, animations:...) to a whole new level!"
  s.description      = <<-DESC
	EasyAnimation extends the animation methods that are built-in in UIKit and allows you to:
	
	* animate layer properties from within animateWithDuration:animations:
	* mix view and layer animations together
	* spring animations for view and layers
	* chain easily animation together
	* cancel animation chains
	
                       DESC
  s.homepage         = "https://github.com/icanzilb/EasyAnimation"
  s.screenshots      = "https://raw.githubusercontent.com/icanzilb/EasyAnimation/master/etc/EA.png"
  s.license          = 'MIT'
  s.author           = { "Marin Todorov" => "touch-code-magazine@underplot.com" }
  s.source           = { :git => "https://github.com/icanzilb/EasyAnimation.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/icanzilb'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'EasyAnimation/**/*.swift'
end
