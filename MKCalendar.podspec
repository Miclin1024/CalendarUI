#  Be sure to run `pod spec lint MKCalendar.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
Pod::Spec.new do |spec|

  spec.name         = "MKCalendar"
  spec.version      = "0.0.6"
  spec.swift_version = ["5.1", "5.2", "5.3"]
  spec.summary      = "A customizable calendar framework for iOS"

  spec.homepage     = "https://github.com/Miclin1024/MKCalendar/"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Michael Lin" => "miclin@berkeley.edu" }

  spec.platform     = :ios, "12.0"
  spec.ios.deployment_target = "12.0"

  spec.source       = { :git => "https://github.com/Miclin1024/MKCalendar.git", :tag => spec.version.to_s }
  spec.source_files  = "Sources/**/*.swift"
  spec.framework  = "UIKit"

end
