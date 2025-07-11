require 'rails_helper'

RSpec.describe 'Test environment variable' do
  it 'uses test envvar' do
    expect(ENV['TEST_ENV_VAR']).to eq('true')
  end
end
