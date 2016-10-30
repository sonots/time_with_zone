# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'time_with_zone/version'

Gem::Specification.new do |spec|
  spec.name          = "time_with_zone"
  spec.version       = TimeWithZone::VERSION
  spec.authors       = ["sonots"]
  spec.email         = ["sonots@gmail.com"]

  spec.summary       = %q{Handle time with zone withtout ActiveSupport or ENV['TZ']}
  spec.description   = %q{Handle time with zone withtout ActiveSupport or ENV['TZ']}
  spec.homepage      = "https://github.com/sonots/time_with_zone"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tzinfo"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
