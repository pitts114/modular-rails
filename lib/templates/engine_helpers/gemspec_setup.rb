# frozen_string_literal: true

# Sets up the gemspec file with pre-filled information
class GemspecSetup
  def initialize(engine_path, engine_name)
    @engine_path = engine_path
    @engine_name = engine_name
  end

  def perform
    gemspec_path = File.join(@engine_path, "#{@engine_name}.gemspec")
    File.write(gemspec_path, gemspec_content)
  end

  private

  def gemspec_content
    module_name = @engine_name.split("_").map(&:capitalize).join

    <<~RUBY
      require_relative "lib/#{@engine_name}/version"

      Gem::Specification.new do |spec|
        spec.name        = "#{@engine_name}"
        spec.version     = #{module_name}::VERSION
        spec.authors     = ["Your Name"]
        spec.email       = ["your.email@example.com"]
        spec.homepage    = "https://example.com"
        spec.summary     = "#{@engine_name.gsub('_', ' ').capitalize} engine for modular Rails app"
        spec.description = "#{@engine_name.gsub('_', ' ').capitalize} domain module for the application"
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
      end
    RUBY
  end
end
