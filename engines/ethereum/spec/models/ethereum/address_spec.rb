require 'rails_helper'

RSpec.describe Ethereum::Address, type: :model do
  subject { described_class.new(address: '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045') }

  it 'is valid with a unique address' do
    expect(subject).to be_valid
  end

  it 'is not valid without an address' do
    subject.address = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:address]).to include("can't be blank")
  end

  it 'is not valid with a duplicate address' do
    described_class.create!(address: subject.address)
    duplicate = described_class.new(address: subject.address)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:address]).to include('has already been taken')
  end
end
