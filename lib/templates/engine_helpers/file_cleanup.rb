# frozen_string_literal: true

require "fileutils"

# Handles cleanup of generated files that we don't want
class FileCleanup
  def initialize(engine_path, engine_name, root_path)
    @engine_path = engine_path
    @engine_name = engine_name
    @root_path = root_path
  end

  def perform
    remove_github_directory
    remove_engine_gemfile
    remove_engine_from_main_gemfile
    remove_bin_files
  end

  private

  def remove_github_directory
    github_dir = File.join(@engine_path, ".github")
    if Dir.exist?(github_dir)
      FileUtils.rm_rf(github_dir)
    end
  end

  def remove_engine_gemfile
    engine_gemfile = File.join(@engine_path, "Gemfile")
    if File.exist?(engine_gemfile)
      FileUtils.rm(engine_gemfile)
    end
  end

  def remove_engine_from_main_gemfile
    main_gemfile = File.join(@root_path, "Gemfile")
    return unless File.exist?(main_gemfile)

    gemfile_content = File.read(main_gemfile)
    # Remove lines like: gem "engine_name", ...
    new_content = gemfile_content.gsub(/^gem ["']#{@engine_name}["'].*\n/, "")

    if new_content != gemfile_content
      File.write(main_gemfile, new_content)
    end
  end

  def remove_bin_files
    bin_dir = File.join(@engine_path, "bin")
    return unless Dir.exist?(bin_dir)

    # Remove rubocop bin file since we'll use the main app's rubocop
    rubocop_bin = File.join(bin_dir, "rubocop")
    FileUtils.rm(rubocop_bin) if File.exist?(rubocop_bin)

    # Remove the entire bin directory if it's empty after cleanup
    if Dir.empty?(bin_dir)
      FileUtils.rmdir(bin_dir)
    end
  end
end
