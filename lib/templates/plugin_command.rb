# frozen_string_literal: true

# Handles the rails plugin new command construction
class PluginCommand
  def initialize(engine_path)
    @engine_path = engine_path
  end

  def to_s
    [
      "rails plugin new #{@engine_path}",
      "--full",
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
  end
end
