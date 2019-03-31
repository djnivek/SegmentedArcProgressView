Pod::Spec.new do |s|
  s.name         = "SegmentedArcProgressView"
  s.version      = "0.2.1"
  s.summary      = "UI Component - Progress View"
  s.description  = <<-DESC
    SegmentedArcProgressView is a UI Component
  DESC
  s.homepage     = "https://github.com/djnivek/SegmentedArcProgressView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Kevin Machado" => "machadokevin.dev@gmail.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/djnivek/SegmentedArcProgressView.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "UIKit"
end
