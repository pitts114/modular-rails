# frozen_string_literal: true

# Rails template for generating a mountable engine without isolated namespace
# Usage: rails app:template LOCATION=lib/templates/engine_no_namespace.rb

require "fileutils"
require "pathname"

# Prompt for engine name
def ask_engine_name
  engine_name = ask("Engine name (snake_case, e.g. users):")
  abort("Engine name required!") if engine_name.strip.empty?
  engine_name.strip
end

engine_name = ask_engine_name
engine_path = File.join("engines", engine_name)

# Generate the engine
say "Generating mountable engine '#{engine_name}' in engines/"
plugin_new_cmd = [
  "rails plugin new #{engine_path}",
  "--mountable",
  "--skip-git",
  "--skip-makefile",
  "--skip-test",
  "--skip-action-text",
  "--skip-action-cable",
  "--skip-action-mailer",
  "--skip-sprockets",
  "--skip-javascript",
  "--skip-turbolinks",
  "--skip-test",
  "--skip-system-test",
  "--skip-gemfile-entry",
  "--skip-github"
].join(" ")
run plugin_new_cmd

# Remove .github directory if it exists
engine_github_dir = File.join(engine_path, ".github")
if Dir.exist?(engine_github_dir)
  FileUtils.rm_rf(engine_github_dir)
end

# Remove the engine's Gemfile if it exists
engine_gemfile = File.join(engine_path, "Gemfile")
if File.exist?(engine_gemfile)
  FileUtils.rm(engine_gemfile)
end

# Remove any gem line for the engine from the main Gemfile
main_gemfile = File.expand_path("../../../Gemfile", __FILE__)
if File.exist?(main_gemfile)
  gemfile_content = File.read(main_gemfile)
  # Remove lines like: gem "engine_name", ...
  new_content = gemfile_content.gsub(/^gem ["']#{engine_name}["'].*\n/, "")
  File.write(main_gemfile, new_content) if new_content != gemfile_content
end

# Add rspec-rails to the engine's gemspec
gemspec_path = File.join(engine_path, "#{engine_name}.gemspec")
if File.exist?(gemspec_path)
  gemspec = File.read(gemspec_path)
  unless gemspec.include?("rspec-rails")
    gemspec.sub!(/(spec.add_development_dependency\s+"bundler".*\n)/, "\\1  spec.add_development_dependency \"rspec-rails\"\n")
    File.write(gemspec_path, gemspec)
  end
end

# Install dependencies and set up RSpec
dir = Dir.pwd
Dir.chdir(engine_path) do
  run "bundle install"
  run "bundle exec rails generate rspec:install"
end
Dir.chdir(dir)

# Overwrite engine's rails_helper.rb and spec_helper.rb to require root helpers using static relative paths
engine_spec_dir = File.join(engine_path, "spec")

rails_helper_path = File.expand_path(File.join(engine_spec_dir, "rails_helper.rb"))
spec_helper_path = File.expand_path(File.join(engine_spec_dir, "spec_helper.rb"))

File.write(rails_helper_path, "require_relative '../../../spec/rails_helper'\n")
File.write(spec_helper_path, "require_relative '../../../spec/spec_helper'\n")

# Remove config/routes.rb
engine_routes = File.join(engine_path, "config", "routes.rb")
config_dir = File.join(engine_path, "config")
FileUtils.rm(engine_routes) if File.exist?(engine_routes)
FileUtils.rmdir(config_dir) if Dir.exist?(config_dir)

say "Engine '#{engine_name}' created in engines/#{engine_name} without isolated namespace."
