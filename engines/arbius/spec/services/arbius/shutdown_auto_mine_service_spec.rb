require 'rails_helper'

RSpec.describe Arbius::ShutdownAutoMineService do
  let(:flipper) { double(:flipper, disable: true) }
  subject(:service) { described_class.new(flipper: flipper) }

  it 'disables the bulk_bogus_auto_mine feature' do
    service.call
    expect(flipper).to have_received(:disable).with(:bulk_bogus_auto_mine)
  end
end
