# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mini_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "mini_deploy"
  spec.version       = MiniDeploy::VERSION
  spec.authors       = ["Guanting Chen"]
  spec.email         = ["cgt886@gmail.com "]
  spec.summary       = %q{Mini Deployment Tool}
  spec.description   = %q{Upload Script to Remote Server}
  spec.homepage      = "https://github.com/guanting112/mini_deploy"
  spec.license       = "MIT"
  spec.platform      = Gem::Platform::RUBY
  spec.required_ruby_version = '~> 2'


  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'pretty_console_output', '~> 1.0'
  spec.add_runtime_dependency 'http', '~> 2.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency "thor", "~> 0.18"
end
