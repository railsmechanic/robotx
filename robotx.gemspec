# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "robotx"
  spec.version       = "0.1.0"
  spec.authors       = ["Matthias Kalb"]
  spec.email         = ["matthias.kalb@railsmechanic.de"]
  spec.summary       = %q{A parser for the robots.txt file}
  spec.description   = %q{A simple to use parser for the robots.txt file.}
  spec.homepage      = "https://github.com/railsmechanic/robotx"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
