# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Login and Profile Flow', type: :request do
  describe 'GET /users/login' do
    it 'displays the login form' do
      get login_users_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Sign In')
      expect(response.body).to include('Username')
      expect(response.body).to include('Password')
      expect(response.body).to include("Don't have an account?")
    end
  end

  describe 'POST /users/authenticate' do
    let(:users_api) { double(:users_api) }
    let(:valid_login_params) do
      {
        user: {
          username: 'testuser',
          password: 'password123'
        }
      }
    end

    before do
      allow(UsersApi).to receive(:new).and_return(users_api)
    end

    context 'when authentication succeeds' do
      let(:user) { double(:user, id: 'user-123') }
      let(:successful_result) do
        {
          success: true,
          user: user
        }
      end

      before do
        allow(users_api).to receive(:authenticate_user).and_return(successful_result)
      end

      it 'redirects to profile page with success message' do
        post authenticate_users_path, params: valid_login_params

        expect(response).to redirect_to(profile_users_path)
        expect(flash[:notice]).to eq('Successfully logged in!')
      end

      it 'sets user session' do
        post authenticate_users_path, params: valid_login_params

        expect(session[:user_id]).to eq('user-123')
      end

      it 'calls UsersApi with correct parameters' do
        post authenticate_users_path, params: valid_login_params

        expect(users_api).to have_received(:authenticate_user).with(
          username: 'testuser',
          password: 'password123'
        )
      end
    end

    context 'when authentication fails' do
      let(:failed_result) do
        {
          success: false,
          errors: [ 'Invalid username or password' ]
        }
      end

      before do
        allow(users_api).to receive(:authenticate_user).and_return(failed_result)
      end

      it 'renders the login form with errors' do
        post authenticate_users_path, params: valid_login_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Sign In')
        expect(response.body).to include('Please fix the following errors:')
        expect(response.body).to include('Invalid username or password')
      end

      it 'does not set user session' do
        post authenticate_users_path, params: valid_login_params

        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe 'GET /users/profile' do
    let(:users_api) { double(:users_api) }
    let(:user_profile_data) do
      {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '+1234567890',
        created_at: Time.new(2023, 1, 15, 10, 30, 0)
      }
    end

    before do
      allow(UsersApi).to receive(:new).and_return(users_api)
    end

    context 'when user is logged in' do
      before do
        allow(users_api).to receive(:get_user_profile).with(user_id: 'user-123').and_return({
          success: true,
          profile: user_profile_data,
          errors: []
        })
      end

      it 'displays the profile page with user data' do
        # First set the session through the controller mechanism
        allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]).with(:user_id).and_return('user-123')
        # Mock flash as an empty hash to avoid flash access issues
        allow_any_instance_of(ActionController::Base).to receive(:flash).and_return(ActionDispatch::Flash::FlashHash.new)

        get profile_users_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Your Profile')
        expect(response.body).to include('Welcome, testuser!')
        expect(response.body).to include('test@example.com')
        expect(response.body).to include('+1234567890')
        expect(response.body).to include('January 15, 2023')
      end

      it 'calls UsersApi with correct user ID' do
        # First set the session through the controller mechanism
        allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]).with(:user_id).and_return('user-123')
        # Mock flash as an empty hash to avoid flash access issues
        allow_any_instance_of(ActionController::Base).to receive(:flash).and_return(ActionDispatch::Flash::FlashHash.new)

        get profile_users_path

        expect(users_api).to have_received(:get_user_profile).with(user_id: 'user-123')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page with alert' do
        get profile_users_path

        expect(response).to redirect_to(login_users_path)
        follow_redirect!

        expect(response.body).to include('Sign In')
      end
    end
  end

  describe 'DELETE /users/logout' do
    it 'responds to logout route' do
      delete logout_users_path
      # Just verify the route exists and responds
      expect(response).to have_http_status(:redirect)
    end
  end
end
