require_relative "lib/admin/version"

Gem::Specification.new do |spec|
  spec.name        = "admin"
  spec.version     = Admin::VERSION
  spec.authors     = [ "Arbius Team" ]
  spec.email       = [ "team@arbius.ai" ]
  spec.homepage    = "https://github.com/pitts114/arbius-command-center"
  spec.summary     = "Admin engine for Arbius Command Center."
  spec.description = "Admin engine for Arbius Command Center."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pitts114/arbius-command-center"
  spec.metadata["changelog_uri"] = "https://github.com/pitts114/arbius-command-center/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"
end
