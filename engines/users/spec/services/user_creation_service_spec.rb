# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserCreationService do
  let(:active_record_base) { double(:active_record_base) }
  let(:user_model) { double(:user_model) }
  let(:user_signup_info_model) { double(:user_signup_info_model) }
  let(:logger) { double(:logger) }
  let(:notifications) { double(:notifications) }
  let(:user) { double(:user, id: 'user-id-123', username: 'testuser', created_at: Time.zone.parse('2025-01-01 12:00:00'), user_signup_info: user_signup_info) }
  let(:user_signup_info) { double(:user_signup_info, email: 'test@example.com', phone_number: '+1234567890') }
  let(:user_errors) { double(:user_errors) }
  let(:signup_info_errors) { double(:signup_info_errors) }

  let(:service) do
    described_class.new(
      active_record_base: active_record_base,
      user_model: user_model,
      user_signup_info_model: user_signup_info_model,
      logger: logger,
      notifications: notifications
    )
  end

  let(:valid_params) do
    {
      username: 'testuser',
      password: 'password123',
      email: 'test@example.com',
      phone_number: '+1234567890'
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      before do
        allow(active_record_base).to receive(:transaction).and_yield
        allow(user_model).to receive(:create!).and_return(user)
        allow(user).to receive(:create_user_signup_info!).and_return(user_signup_info)
        allow(user).to receive(:id).and_return('user-id-123')
        allow(user).to receive(:username).and_return('testuser')
        allow(user).to receive(:created_at).and_return(Time.zone.parse('2025-01-01 12:00:00'))
        allow(user).to receive(:user_signup_info).and_return(user_signup_info)
        allow(user_signup_info).to receive(:email).and_return('test@example.com')
        allow(user_signup_info).to receive(:phone_number).and_return('+1234567890')
        allow(notifications).to receive(:instrument)
        allow(logger).to receive(:info)
      end

      it 'creates a user with the provided parameters' do
        expect(user_model).to receive(:create!).with(username: 'testuser', password: 'password123').and_return(user)

        user_result, errors = service.call(**valid_params)
        expect(user_result).to eq(user)
        expect(errors).to be_empty
      end

      it 'creates user signup info with the provided parameters' do
        expect(user).to receive(:create_user_signup_info!).with(email: 'test@example.com', phone_number: '+1234567890').and_return(user_signup_info)

        user_result, errors = service.call(**valid_params)
        expect(user_result).to eq(user)
        expect(errors).to be_empty
      end

      it 'returns the created user with no errors' do
        user_result, errors = service.call(**valid_params)
        expect(user_result).to eq(user)
        expect(errors).to eq([])
      end

      it 'emits UserCreated event with correct payload' do
        expected_payload = {
          user_id: 'user-id-123',
          username: 'testuser',
          email: 'test@example.com',
          phone_number: '+1234567890',
          created_at: Time.zone.parse('2025-01-01 12:00:00')
        }

        expect(notifications).to receive(:instrument).with('users.user_created', expected_payload)
        expect(logger).to receive(:info).with("UserCreated event emitted for user: user-id-123")

        service.call(**valid_params)
      end
    end

    context 'when user creation fails' do
      let(:user_errors) { double(:user_errors) }
      let(:invalid_user) do
        # Create a more realistic mock that includes ActiveRecord behavior
        user_mock = double(:user, errors: user_errors, user_signup_info: nil)
        allow(user_mock).to receive(:class).and_return(double(i18n_scope: :activerecord))
        user_mock
      end

      before do
        allow(user_errors).to receive(:any?).and_return(true)
        allow(user_errors).to receive(:full_messages).and_return([ "Username can't be blank" ])
        allow(active_record_base).to receive(:transaction).and_yield
        allow(user_model).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(invalid_user))
      end

      it 'returns the user with validation errors' do
        _, errors = service.call(**valid_params.merge(username: ''))
        expect(errors).to eq([ "Username can't be blank" ])
      end
    end

    context 'when user signup info creation fails' do
      let(:signup_info_errors) { double(:signup_info_errors) }
      let(:invalid_signup_info) do
        signup_mock = double(:signup_info, errors: signup_info_errors)
        allow(signup_mock).to receive(:class).and_return(double(i18n_scope: :activerecord))
        signup_mock
      end

      before do
        allow(signup_info_errors).to receive(:any?).and_return(true)
        allow(signup_info_errors).to receive(:full_messages).and_return([ 'Email is invalid' ])
        allow(active_record_base).to receive(:transaction).and_yield
        allow(user_model).to receive(:create!).and_return(user)
        allow(user).to receive(:create_user_signup_info!).and_raise(ActiveRecord::RecordInvalid.new(invalid_signup_info))
      end

      it 'returns the user with validation errors' do
        user_result, errors = service.call(**valid_params.merge(email: 'invalid-email'))
        expect(user_result).to be_nil  # Transaction rolled back, no user persisted
        expect(errors).to eq([ 'Email is invalid' ])
      end
    end

    context 'error collection from both user and signup info' do
      let(:user_errors) { double(:user_errors) }
      let(:signup_info_errors) { double(:signup_info_errors) }
      let(:complex_user) do
        user_mock = double(:user, errors: user_errors, user_signup_info: user_signup_info)
        allow(user_mock).to receive(:class).and_return(double(i18n_scope: :activerecord))
        user_mock
      end

      before do
        allow(user_errors).to receive(:any?).and_return(true)
        allow(user_errors).to receive(:full_messages).and_return([ 'User error 1', 'User error 2' ])
        allow(signup_info_errors).to receive(:any?).and_return(true)
        allow(signup_info_errors).to receive(:full_messages).and_return([ 'Signup error 1' ])
        allow(user_signup_info).to receive(:errors).and_return(signup_info_errors)
        allow(active_record_base).to receive(:transaction).and_yield
        allow(user_model).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(complex_user))
      end

      it 'returns the user with validation errors from both models' do
        _, errors = service.call(**valid_params)
        expect(errors).to eq([ 'User error 1', 'User error 2', 'Signup error 1' ])
      end
    end
  end
end
