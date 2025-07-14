# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersApi do
  let(:user_creation_service) { double(:user_creation_service) }
  let(:user_model) { double(:user_model) }
  let(:user_authentication_service) { double(:user_authentication_service) }
  let(:user_profile_service) { double(:user_profile_service) }
  let(:user) { double(:user) }
  let(:api) { described_class.new(user_creation_service: user_creation_service, user_model: user_model, user_authentication_service: user_authentication_service, user_profile_service: user_profile_service) }

  let(:valid_params) do
    {
      username: 'testuser',
      password: 'password123',
      email: 'test@example.com',
      phone_number: '+1234567890'
    }
  end

  describe '#create_user' do
    context 'with valid parameters' do
      let(:persisted_user) { double(:user, persisted?: true) }

      before do
        allow(user_creation_service).to receive(:call).with(**valid_params).and_return([ persisted_user, [] ])
      end

      it 'returns success result' do
        result = api.create_user(**valid_params)

        expect(result[:success]).to be true
        expect(result[:user]).to eq(persisted_user)
        expect(result[:errors]).to be_empty
      end

      it 'calls the service with correct parameters' do
        expect(user_creation_service).to receive(:call).with(**valid_params)
        api.create_user(**valid_params)
      end
    end

    context 'with invalid parameters' do
      let(:validation_errors) { [ "Username can't be blank" ] }

      before do
        allow(user_creation_service).to receive(:call).with(**valid_params.merge(username: '')).and_return([ nil, validation_errors ])
      end

      it 'returns failure result for invalid username' do
        result = api.create_user(**valid_params.merge(username: ''))

        expect(result[:success]).to be false
        expect(result[:user]).to be_nil
        expect(result[:errors]).to include("Username can't be blank")
      end
    end

    context 'when service raises an error' do
      before do
        allow(user_creation_service).to receive(:call).and_raise(StandardError.new('Database connection failed'))
      end

      it 'returns failure result with error message' do
        result = api.create_user(**valid_params)

        expect(result[:success]).to be false
        expect(result[:user]).to be_nil
        expect(result[:errors]).to eq([ 'An unexpected error occurred: Database connection failed' ])
      end
    end
  end

  describe '#find_user_by_username' do
    before do
      allow(user_model).to receive(:find_by).with(username: 'testuser').and_return(user)
      allow(user_model).to receive(:find_by).with(username: 'nonexistent').and_return(nil)
    end

    it 'returns success result with user when found' do
      result = api.find_user_by_username(username: 'testuser')
      expect(result).to eq({ success: true, user: user, errors: [] })
    end

    it 'returns failure result when not found' do
      result = api.find_user_by_username(username: 'nonexistent')
      expect(result).to eq({ success: false, user: nil, errors: [ 'User not found' ] })
    end

    context 'when service raises an error' do
      before do
        allow(user_model).to receive(:find_by).and_raise(StandardError.new('Database connection failed'))
      end

      it 'returns failure result with error message' do
        result = api.find_user_by_username(username: 'testuser')
        expect(result).to eq({ success: false, user: nil, errors: [ 'An unexpected error occurred: Database connection failed' ] })
      end
    end
  end

  describe '#authenticate_user' do
    context 'when authentication succeeds' do
      before do
        allow(user_authentication_service).to receive(:call).with(username: 'testuser', password: 'password123').and_return(user)
      end

      it 'returns success result with user' do
        result = api.authenticate_user(username: 'testuser', password: 'password123')

        expect(result[:success]).to be true
        expect(result[:user]).to eq(user)
      end

      it 'calls the authentication service with correct parameters' do
        expect(user_authentication_service).to receive(:call).with(username: 'testuser', password: 'password123')
        api.authenticate_user(username: 'testuser', password: 'password123')
      end
    end

    context 'when password is incorrect' do
      before do
        allow(user_authentication_service).to receive(:call).with(username: 'testuser', password: 'wrongpassword').and_return(nil)
      end

      it 'returns failure result with error message' do
        result = api.authenticate_user(username: 'testuser', password: 'wrongpassword')

        expect(result[:success]).to be false
        expect(result[:errors]).to eq([ 'Invalid username or password' ])
      end
    end

    context 'when user does not exist' do
      before do
        allow(user_authentication_service).to receive(:call).with(username: 'nonexistent', password: 'password123').and_return(nil)
      end

      it 'returns failure result with error message' do
        result = api.authenticate_user(username: 'nonexistent', password: 'password123')

        expect(result[:success]).to be false
        expect(result[:errors]).to eq([ 'Invalid username or password' ])
      end
    end

    context 'when service raises an error' do
      before do
        allow(user_authentication_service).to receive(:call).and_raise(StandardError.new('Database connection failed'))
      end

      it 'returns failure result with error message' do
        result = api.authenticate_user(username: 'testuser', password: 'password123')

        expect(result[:success]).to be false
        expect(result[:errors]).to eq([ 'An unexpected error occurred: Database connection failed' ])
      end
    end
  end

  describe '#get_user_profile' do
    let(:user_profile_data) do
      {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '+1234567890',
        created_at: Time.new(2023, 1, 15, 10, 30, 0)
      }
    end

    context 'when user exists' do
      before do
        allow(user_profile_service).to receive(:call).with(user_id: 'user-123').and_return(user_profile_data)
      end

      it 'returns success result with profile data' do
        result = api.get_user_profile(user_id: 'user-123')

        expect(result).to eq({ success: true, profile: user_profile_data, errors: [] })
      end

      it 'calls the profile service with correct parameters' do
        expect(user_profile_service).to receive(:call).with(user_id: 'user-123')
        api.get_user_profile(user_id: 'user-123')
      end
    end

    context 'when user does not exist' do
      before do
        allow(user_profile_service).to receive(:call).with(user_id: 'nonexistent').and_return(nil)
      end

      it 'returns failure result' do
        result = api.get_user_profile(user_id: 'nonexistent')

        expect(result).to eq({ success: false, profile: nil, errors: [ 'User not found' ] })
      end
    end

    context 'when service raises an error' do
      before do
        allow(user_profile_service).to receive(:call).and_raise(StandardError.new('Database connection failed'))
      end

      it 'returns failure result with error message' do
        result = api.get_user_profile(user_id: 'user-123')

        expect(result).to eq({ success: false, profile: nil, errors: [ 'An unexpected error occurred: Database connection failed' ] })
      end
    end
  end
end
