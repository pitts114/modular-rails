# frozen_string_literal: true

require "fileutils"

# Removes the config directory and routes.rb since we don't need isolated routing
class ConfigCleanup
  def initialize(engine_path)
    @engine_path = engine_path
  end

  def perform
    remove_routes_file
    remove_config_directory_if_empty
  end

  private

  def config_directory
    @config_directory ||= File.join(@engine_path, "config")
  end

  def routes_file
    @routes_file ||= File.join(config_directory, "routes.rb")
  end

  def remove_routes_file
    FileUtils.rm(routes_file) if File.exist?(routes_file)
  end

  def remove_config_directory_if_empty
    if Dir.exist?(config_directory) && Dir.empty?(config_directory)
      FileUtils.rmdir(config_directory)
    end
  end
end
