Pod::Spec.new do |s|
  s.name         = "RapidAPISDK"
  s.version      = "0.1"
  s.summary      = "Find, try and connect to APIs easily with the RapidAPI marketplace"
  s.description  = <<-DESC
  RapidAPI is the world's first opensource API marketplace. It allows developers to discover and connect to the world's top APIs more easily and manage multiple API connections in one place.
		   DESC
  s.homepage     = "https://rapidapi.com"
  s.license      = "Apache License, Version 2.0"

  s.author       = { "bukati" => "andrey@rapidapi.com" }
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/RapidSoftwareSolutions/rapidapi-ios-sdk.git", :tag => s.version, :submodules => true }

  s.source_files  = "RapidConnectSDK/*.{h,m}"
  s.public_header_files = "RapidConnectSDK/RapidConnectSDK.h"

  s.requires_arc = true
  s.documentation_url  = "https://github.com/RapidSoftwareSolutions/rapidapi-ios-sdk/blob/master/README.md"
end
