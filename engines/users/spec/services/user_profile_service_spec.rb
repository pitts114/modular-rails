# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserProfileService do
  let(:user_model) { double(:user_model) }
  let(:service) { described_class.new(user_model: user_model) }

  describe '#call' do
    let(:user) do
      double(:user,
        id: 'user-123',
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '+1234567890',
        created_at: Time.new(2023, 1, 15, 10, 30, 0)
      )
    end

    context 'when user exists' do
      before do
        allow(user_model).to receive(:find_by).with(id: 'user-123').and_return(user)
      end

      it 'returns user profile data' do
        result = service.call(user_id: 'user-123')

        expect(result).to eq({
          username: 'testuser',
          email: 'test@example.com',
          phone_number: '+1234567890',
          created_at: Time.new(2023, 1, 15, 10, 30, 0)
        })
      end
    end

    context 'when user does not exist' do
      before do
        allow(user_model).to receive(:find_by).with(id: 'nonexistent').and_return(nil)
      end

      it 'returns nil' do
        result = service.call(user_id: 'nonexistent')

        expect(result).to be_nil
      end
    end
  end
end
