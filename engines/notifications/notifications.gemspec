require_relative "lib/notifications/version"

Gem::Specification.new do |spec|
  spec.name        = "notifications"
  spec.version     = Notifications::VERSION
  spec.authors     = ["Your Name"]
  spec.email       = ["your.email@example.com"]
  spec.homepage    = "https://example.com"
  spec.summary     = "Notifications engine for modular Rails app"
  spec.description = "Notifications domain module for the application"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org since it's for internal use
  spec.metadata["allowed_push_host"] = "none"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com"
  spec.metadata["changelog_uri"] = "https://example.com/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.require_paths = ["lib"]

  # Add dependencies for this engine here
  # Example: spec.add_dependency "some_gem", "~> 1.0"
  spec.add_dependency "core"
  spec.add_dependency "users"
end
