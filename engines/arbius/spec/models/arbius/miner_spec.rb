require 'rails_helper'

RSpec.describe Arbius::Miner, type: :model do
  subject { described_class.new(address: '0x1234567890abcdef') }

  describe 'validations' do
    it 'is valid with a valid address' do
      expect(subject).to be_valid
    end

    it 'is invalid without an address' do
      subject.address = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:address]).to include("can't be blank")
    end
  end
end
