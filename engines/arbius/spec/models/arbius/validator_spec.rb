require 'rails_helper'

RSpec.describe Arbius::Validator, type: :model do
  subject { described_class.new(address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045') }

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
