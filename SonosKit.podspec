Pod::Spec.new do |s|
  s.name = "SonosKit"
  s.version = "0.1.0"
  s.description = "A library for building applications to control Sonos hardware."
  s.summary = "Objective-C API for controlling Sonos hardware."
  s.homepage = "http://github.com/nathanborror/SonosKit"
  s.license = "GPL v3"
  s.author = {"Nathan Borror" => "nathan@nathanborror.com"}
  s.source = {:git => "https://github.com/nathanborror/SonosKit.git", :tag => s.version.to_s}
  s.osx.deployment_target = '10.9'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
  s.source_files = "SonosKit/**/*.{h,m}"
  s.public_header_files = "SonosKit/**/*.h"
  s.dependency "CocoaAsyncSocket", "7.3.3"
  s.dependency "XMLReader", "0.0.2"
end
