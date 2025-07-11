# engines/ethereum/spec/rails_helper.rb
require File.expand_path('../../../../spec/rails_helper', __FILE__)

# FactoryBot setup for RSpec
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
