# frozen_string_literal: true

# Sets up Rakefile for the engine
class RakefileSetup
  def initialize(engine_path)
    @engine_path = engine_path
  end

  def perform
    rakefile_path = File.join(@engine_path, "Rakefile")
    File.write(rakefile_path, rakefile_content)
  end

  private

  def rakefile_content
    <<~RUBY
      require "bundler/setup"

      Dir.glob(File.expand_path("lib/tasks/**/*.rake", __dir__)).each { |r| load r }
    RUBY
  end
end
