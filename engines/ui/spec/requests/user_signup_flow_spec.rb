# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Signup Flow', type: :request do
  describe 'GET /' do
    it 'displays the signup form' do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Create Your Account')
      expect(response.body).to include('Username')
      expect(response.body).to include('Password')
      expect(response.body).to include('Email')
      expect(response.body).to include('Phone Number (optional)')
    end
  end

  describe 'GET /users/new' do
    it 'displays the signup form' do
      get new_user_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Create Your Account')
    end
  end

  describe 'POST /users' do
    let(:users_api) { double(:users_api) }
    let(:valid_params) do
      {
        user: {
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          phone_number: '555-1234'
        }
      }
    end

    before do
      allow(UsersApi).to receive(:new).and_return(users_api)
    end

    context 'when user creation succeeds' do
      let(:successful_result) do
        {
          success: true,
          user: double(:user, id: 'user-123', username: 'testuser')
        }
      end

      before do
        allow(users_api).to receive(:create_user).and_return(successful_result)
      end

      it 'redirects to success page with notice' do
        post users_path, params: valid_params

        expect(response).to redirect_to(success_users_path)
        follow_redirect!

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Account Created Successfully!')
      end

      it 'sets success flash message' do
        post users_path, params: valid_params

        expect(flash[:notice]).to eq('Account created successfully!')
      end

      it 'calls UsersApi with correct parameters' do
        post users_path, params: valid_params

        expect(users_api).to have_received(:create_user).with(
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          phone_number: '555-1234'
        )
      end
    end

    context 'when user creation fails' do
      let(:failed_result) do
        {
          success: false,
          errors: [ 'Username is already taken', 'Email format is invalid' ]
        }
      end

      before do
        allow(users_api).to receive(:create_user).and_return(failed_result)
      end

      it 'renders the signup form with errors' do
        post users_path, params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Create Your Account')
        expect(response.body).to include('Please fix the following errors:')
        expect(response.body).to include('Username is already taken')
        expect(response.body).to include('Email format is invalid')
      end

      it 'does not set success flash message' do
        post users_path, params: valid_params

        expect(flash[:notice]).to be_nil
      end
    end

    context 'parameter structure validation' do
      let(:successful_result) do
        {
          success: true,
          user: double(:user, id: 'user-123', username: 'testuser')
        }
      end

      before do
        allow(users_api).to receive(:create_user).and_return(successful_result)
      end

      it 'correctly processes nested user parameters' do
        # This test ensures the form sends parameters in the correct nested structure
        # and would have caught the missing scope: :user issue
        post users_path, params: {
          user: {
            username: 'testuser',
            password: 'password123',
            email: 'test@example.com',
            phone_number: '555-1234'
          }
        }

        expect(response).to redirect_to(success_users_path)
        expect(users_api).to have_received(:create_user).with(
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          phone_number: '555-1234'
        )
      end
    end
  end

  describe 'GET /users/success' do
    it 'displays the success page' do
      get success_users_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Account Created Successfully!')
      expect(response.body).to include('Welcome!')
      expect(response.body).to include('Go to Home')
    end
  end
end
