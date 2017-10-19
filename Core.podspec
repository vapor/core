Pod::Spec.new do |spec|
  spec.name         = 'Core'
  spec.version      = '2.1.2'
  spec.license      = 'MIT'
  spec.homepage     = 'https://github.com/vapor/core'
  spec.authors      = { 'Vapor' => 'contact@vapor.codes' }
  spec.summary      = 'Core extensions, type-aliases, and functions that facilitate common tasks.'
  spec.source       = { :git => "#{spec.homepage}.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.9"
  spec.watchos.deployment_target = "2.0"
  spec.tvos.deployment_target = "9.0"
  spec.requires_arc = true
  spec.social_media_url = 'https://twitter.com/codevapor'
  spec.default_subspec = "Default"

  spec.subspec "Default" do |ss|
    ss.source_files = 'Sources/Core/**/*.{swift}'
    ss.dependency 'Bits', '~> 1.1.0'
    ss.dependency 'Debugging', '~> 1.1.0'
    ss.dependency 'Core/libc'
  end

  spec.subspec "libc" do |ss|
    ss.source_files = 'Sources/libc/**/*.{swift}'
  end

end
