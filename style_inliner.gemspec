lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "style_inliner/version"

Gem::Specification.new do |spec|
  spec.name          = "style_inliner"
  spec.version       = StyleInliner::VERSION
  spec.authors       = ["Ryo Nakamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.summary       = "Inline CSS style rules into style attributes of each HTML element."
  spec.homepage      = "https://github.com/r7kamura/style_inliner"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.require_paths = ["lib"]
  spec.add_dependency "css_parser"
  spec.add_dependency "nokogiri"
  spec.add_development_dependency "activesupport", "4.2.6"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.4.0"
end
