# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserAuthenticationService do
  let(:user_model) { double(:user_model) }
  let(:user) { double(:user) }
  let(:service) { described_class.new(user_model: user_model) }

  describe '#call' do
    before do
      allow(user_model).to receive(:find_by).with(username: 'testuser').and_return(user)
      allow(user_model).to receive(:find_by).with(username: 'nonexistent').and_return(nil)
    end

    context 'when authentication succeeds' do
      before do
        allow(user).to receive(:authenticate).with('password123').and_return(user)
      end

      it 'returns the authenticated user' do
        result = service.call(username: 'testuser', password: 'password123')

        expect(result).to eq(user)
      end
    end

    context 'when password is incorrect' do
      before do
        allow(user).to receive(:authenticate).with('wrongpassword').and_return(false)
      end

      it 'returns nil' do
        result = service.call(username: 'testuser', password: 'wrongpassword')

        expect(result).to be_nil
      end
    end

    context 'when user does not exist' do
      it 'returns nil' do
        result = service.call(username: 'nonexistent', password: 'password123')

        expect(result).to be_nil
      end
    end
  end
end
