source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "redis"

gem "sinatra", "~> 2.2"

gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-resque"

gem "csv"

gem 'karafka'
gem 'ruby-kafka'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "rspec", "~> 3.13", groups: [ :development, :test ]

  gem "rspec-rails"
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "factory_bot_rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

gem "resque"

# Scan for engine dependencies
# This section scans the engines directory for gemspec files and adds them to the Gemfile.
# It also handles circular dependencies by maintaining a stack of currently scanned engines.
require "rubygems"
require "set"
engine_dependencies = Set.new
circular_stack = []

def scan_for_engine_dependencies(engine, engine_dependencies = Set.new, circular_stack = [])
  path = File.expand_path("engines/", __dir__)
  engine_path = File.join(path, engine)
  return unless File.directory?(engine_path)
  if circular_stack.include?(engine)
    raise "Circular dependency detected: #{(circular_stack + [ engine ]).join(' -> ')}"
  end
  return if engine_dependencies.include?(engine)
  engine_dependencies << engine
  circular_stack.push(engine)
  gemspec_file = File.join(engine_path, "#{engine}.gemspec")
  if File.exist?(gemspec_file)
    spec = Gem::Specification.load(gemspec_file)
    spec.dependencies.each do |dep|
      scan_for_engine_dependencies(dep.name, engine_dependencies, circular_stack)
    end
  end
  circular_stack.pop
end

# Scan all engines and add them and their dependencies to the global group
Dir.glob(File.expand_path("engines/*", __dir__)).each do |path|
  engine = File.basename(path)
  scan_for_engine_dependencies(engine, engine_dependencies, circular_stack)
end

engine_dependencies.each do |engine|
  gem engine, path: "engines/#{engine}", require: true
end

gem "users", path: "engines/users"
