
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flow_subscribers/version"

Gem::Specification.new do |spec|
  spec.name          = "flow_subscribers"
  spec.version       = Flows::VERSION
  spec.authors       = ["Guilherme Mascarenhas Barbosa"]
  spec.email         = ["gmascb@gmail.com"]

  spec.summary       = %q{A gem that controls the a pattern of services}
  spec.description   = %q{We need to organize our code with some patterns like TDD, SOLID, CLEAN CODE and others!}
  spec.homepage      = "https://github.com/gmascb/flow_subscribers"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://guides.rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/gmascb/flow_subscribers"
    spec.metadata["changelog_uri"] = "https://github.com/gmascb/flow_subscribers"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
