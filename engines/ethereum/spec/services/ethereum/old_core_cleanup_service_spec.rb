# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ethereum::OldCoreCleanupService, type: :service do
  let(:factories) { [ :ethereum_event, :ethereum_transaction ] }
  let(:models) { [ Ethereum::Event, Ethereum::Transaction ] }

  let!(:old_records) { factories.map { |f| create(f, created_at: 2.weeks.ago) } }
  let!(:new_records) { factories.map { |f| create(f, created_at: 2.days.ago) } }

  it "deletes records older than 1 week for all models" do
    expect {
      described_class.call
    }.to change {
      models.map { |m| m.count }
    }.from([ 2, 2 ]).to([ 1, 1 ])

    models.each do |model|
      expect(model.where('created_at < ?', 1.week.ago)).to be_empty
      expect(model.where('created_at >= ?', 1.week.ago).count).to eq(1)
    end
  end

  it "does not delete records newer than the older_than value" do
    expect {
      described_class.call(older_than: 3.days.ago)
    }.to change {
      models.map { |m| m.count }
    }.from([ 2, 2 ]).to([ 1, 1 ])

    models.each do |model|
      expect(model.where('created_at < ?', 3.days.ago)).to be_empty
      expect(model.where('created_at >= ?', 3.days.ago).count).to eq(1)
    end
  end
end
