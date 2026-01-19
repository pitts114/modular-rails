# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserProfileUpdateService do
  let(:user_signup_info_model) { double(:user_signup_info_model) }
  let(:logger) { double(:logger, info: nil) }
  let(:service) { described_class.new(user_signup_info_model: user_signup_info_model, logger: logger) }

  describe '#call' do
    let(:user) { double(:user, id: 'user-123', username: 'testuser') }
    let(:signup_info) do
      double(:signup_info,
        user: user,
        email: 'old@example.com',
        phone_number: '+1111111111',
        update: true,
        errors: double(full_messages: [])
      )
    end

    context 'when user exists' do
      before do
        allow(user_signup_info_model).to receive(:find_by).with(user_id: 'user-123').and_return(signup_info)
      end

      context 'when updating email only' do
        it 'updates the email and returns success' do
          expect(signup_info).to receive(:update).with({ email: 'new@example.com' }).and_return(true)

          user_result, errors = service.call(user_id: 'user-123', email: 'new@example.com')

          expect(user_result).to eq(user)
          expect(errors).to eq([])
          expect(logger).to have_received(:info).with('Profile updated for user: user-123')
        end
      end

      context 'when updating phone number only' do
        it 'updates the phone number and returns success' do
          expect(signup_info).to receive(:update).with({ phone_number: '+9999999999' }).and_return(true)

          user_result, errors = service.call(user_id: 'user-123', phone_number: '+9999999999')

          expect(user_result).to eq(user)
          expect(errors).to eq([])
        end
      end

      context 'when updating both email and phone number' do
        it 'updates both fields and returns success' do
          expect(signup_info).to receive(:update).with({ email: 'new@example.com', phone_number: '+9999999999' }).and_return(true)

          user_result, errors = service.call(user_id: 'user-123', email: 'new@example.com', phone_number: '+9999999999')

          expect(user_result).to eq(user)
          expect(errors).to eq([])
        end
      end

      context 'when no updates provided' do
        it 'returns success without updating' do
          expect(signup_info).not_to receive(:update)

          user_result, errors = service.call(user_id: 'user-123')

          expect(user_result).to eq(user)
          expect(errors).to eq([])
        end
      end

      context 'when update fails' do
        let(:error_messages) { [ 'Email is invalid' ] }

        before do
          allow(signup_info).to receive(:update).and_return(false)
          allow(signup_info.errors).to receive(:full_messages).and_return(error_messages)
        end

        it 'returns nil user and error messages' do
          user_result, errors = service.call(user_id: 'user-123', email: 'invalid-email')

          expect(user_result).to be_nil
          expect(errors).to eq(error_messages)
        end
      end
    end

    context 'when user does not exist' do
      before do
        allow(user_signup_info_model).to receive(:find_by).with(user_id: 'nonexistent').and_return(nil)
      end

      it 'returns nil user and error message' do
        user_result, errors = service.call(user_id: 'nonexistent', email: 'new@example.com')

        expect(user_result).to be_nil
        expect(errors).to eq([ 'User not found' ])
      end
    end
  end
end
