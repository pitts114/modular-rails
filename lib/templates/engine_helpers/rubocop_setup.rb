# frozen_string_literal: true

# Sets up RuboCop configuration for the engine
class RubocopSetup
  def initialize(engine_path)
    @engine_path = engine_path
  end

  def perform
    rubocop_path = File.join(@engine_path, ".rubocop.yml")
    File.write(rubocop_path, rubocop_content)
  end

  private

  def rubocop_content
    <<~YAML
      inherit_from:
      - ../../.rubocop.yml
    YAML
  end
end
