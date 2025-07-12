# frozen_string_literal: true

# Main engine generator class
class EngineGenerator
  attr_reader :engine_name, :engine_path, :root_path

  def initialize(engine_name, root_path = Dir.pwd)
    @engine_name = engine_name.strip
    @root_path = root_path
    @engine_path = File.join(root_path, "engines", engine_name)

    validate_engine_name!
  end

  def generate!
    say "Generating mountable engine '#{engine_name}' in engines/"

    create_plugin
    cleanup_generated_files
    setup_spec_helpers
    setup_rubocop
    setup_rakefile
    remove_config_directory

    say "Engine '#{engine_name}' created in engines/#{engine_name} without isolated namespace."
  end

  private

  def validate_engine_name!
    if engine_name.empty?
      abort("Engine name required!")
    end

    if File.exist?(engine_path)
      abort("Engine '#{engine_name}' already exists!")
    end
  end

  def create_plugin
    plugin_cmd = PluginCommand.new(engine_path)
    run plugin_cmd.to_s
  end

  def cleanup_generated_files
    FileCleanup.new(engine_path, engine_name, root_path).perform
  end

  def setup_spec_helpers
    SpecHelperSetup.new(engine_path).perform
  end

  def setup_rubocop
    RubocopSetup.new(engine_path).perform
  end

  def setup_rakefile
    RakefileSetup.new(engine_path).perform
  end

  def remove_config_directory
    ConfigCleanup.new(engine_path).perform
  end

  # Rails template helper methods
  def say(message)
    if defined?(Rails) && Rails.respond_to?(:logger)
      puts message
    else
      puts message
    end
  end

  def run(command)
    if defined?(Rails.application) && Rails.application.respond_to?(:template_runner)
      # We're in a Rails template context
      `#{command}`
    else
      system(command)
    end
  end
end
