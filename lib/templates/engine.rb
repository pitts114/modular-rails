# frozen_string_literal: true

# Rails template for generating a mountable engine
# Usage: rails app:template LOCATION=lib/templates/engine.rb

# Load all the generator classes
template_dir = File.dirname(__FILE__)
require File.join(template_dir, "engine_generator")

# Prompt for engine name
def ask_engine_name
  engine_name = ask("Engine name (snake_case, e.g. users):")
  abort("Engine name required!") if engine_name.strip.empty?
  engine_name.strip
end

# Generate the engine
engine_name = ask_engine_name
generator = EngineGenerator.new(engine_name, Rails.root.to_s)
generator.generate!
