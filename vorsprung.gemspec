lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vorsprung/version"

Gem::Specification.new do |spec|
  spec.name          = "vorsprung"
  spec.version       = Vorsprung::VERSION
  spec.authors       = ["Built By Kaiser"]
  spec.email         = ["support@builtbykaiser.com"]

  spec.summary       = "Give your Rails app a running start!"
  spec.description   = "Vorsprung generates base Rails applications and stays up-to-date with best practices."
  spec.homepage      = "https://github.com/builtbykaiser/vorsprung"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "bin"
  spec.executables   = ["vorsprung"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> #{Vorsprung::RAILS_VERSION}"
  spec.add_dependency "thor"
  spec.add_dependency "bundler", "~> 1.1" # at least 1.1 for #clean_system

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
