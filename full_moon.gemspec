
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "full_moon/version"

Gem::Specification.new do |spec|
  spec.name          = "full-moon"
  spec.version       = FullMoon::VERSION
  spec.authors       = ["psoliver92"]
  spec.email         = ["psoliver92@gmail.com"]

  spec.summary       = %q{A gem to determine when the next full moon is or if a specific date is a full moon.}
  spec.description   = %q{This gem will provide the next date of the full moon and also determine if a given date is a full moon or not.}
  spec.homepage      = "https://github.com/psoliver92/full_moon"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_runtime_dependency 'activesupport', '>= 5.1.4', '< 6.1.0'
  spec.add_development_dependency 'timecop', '0.8.1'
end
