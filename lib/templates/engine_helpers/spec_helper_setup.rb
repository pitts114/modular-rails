# frozen_string_literal: true

# Sets up spec helper files to inherit from the main app
class SpecHelperSetup
  def initialize(engine_path)
    @engine_path = engine_path
  end

  def perform
    create_spec_directory
    create_rails_helper
    create_spec_helper
  end

  private

  def spec_directory
    @spec_directory ||= File.join(@engine_path, "spec")
  end

  def create_spec_directory
    FileUtils.mkdir_p(spec_directory) unless Dir.exist?(spec_directory)
  end

  def create_rails_helper
    rails_helper_path = File.join(spec_directory, "rails_helper.rb")
    File.write(rails_helper_path, "require_relative '../../../spec/rails_helper'\n")
  end

  def create_spec_helper
    spec_helper_path = File.join(spec_directory, "spec_helper.rb")
    File.write(spec_helper_path, "require_relative '../../../spec/spec_helper'\n")
  end
end
