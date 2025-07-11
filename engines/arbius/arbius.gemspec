require_relative "lib/arbius/version"

Gem::Specification.new do |spec|
  spec.name        = "arbius"
  spec.version     = Arbius::VERSION
  spec.authors     = [ "Arbius Team" ]
  spec.email       = [ "team@arbius.ai" ]
  spec.homepage    = "https://github.com/pitts114/arbius-command-center"
  spec.summary     = "Arbius engine for command center."
  spec.description = "Arbius engine for command center."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pitts114/arbius-command-center"
  spec.metadata["changelog_uri"] = "https://github.com/pitts114/arbius-command-center/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"
  spec.add_dependency "ethereum"
  spec.add_dependency "digest-keccak"
  spec.add_dependency "pagerduty"
  spec.add_dependency "websocket-client-simple"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
end
