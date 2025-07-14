# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#new' do
    it 'renders the signup form' do
      get :new

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    let(:users_api) { double(:users_api) }
    let(:user_params) do
      {
        username: 'testuser',
        password: 'password123',
        email: 'test@example.com',
        phone_number: '555-1234'
      }
    end

    before do
      allow(UsersApi).to receive(:new).and_return(users_api)
    end

    context 'when user creation is successful' do
      let(:successful_result) do
        {
          success: true,
          user: double(:user, id: 'user-123', username: 'testuser')
        }
      end

      before do
        allow(users_api).to receive(:create_user).with(
          username: user_params[:username],
          password: user_params[:password],
          email: user_params[:email],
          phone_number: user_params[:phone_number]
        ).and_return(successful_result)
      end

      it 'redirects to success page with notice' do
        post :create, params: { user: user_params }

        expect(response).to redirect_to(success_users_path)
        expect(flash[:notice]).to eq('Account created successfully!')
      end

      it 'calls UsersApi with correct parameters' do
        post :create, params: { user: user_params }

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
          errors: [ 'Username is already taken', 'Email is invalid' ]
        }
      end

      before do
        allow(users_api).to receive(:create_user).with(
          username: user_params[:username],
          password: user_params[:password],
          email: user_params[:email],
          phone_number: user_params[:phone_number]
        ).and_return(failed_result)
      end

      it 'renders new template with errors' do
        post :create, params: { user: user_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(assigns(:errors)).to eq([ 'Username is already taken', 'Email is invalid' ])
      end

      it 'does not redirect' do
        post :create, params: { user: user_params }

        expect(response).not_to be_redirect
      end
    end

    context 'with missing parameters' do
      it 'raises parameter missing error for missing user params' do
        expect do
          post :create, params: { not_user: user_params }
        end.to raise_error(ActionController::ParameterMissing)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          phone_number: '555-1234',
          admin: true  # Not permitted parameter
        }
      end

      before do
        allow(users_api).to receive(:create_user).with(
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          phone_number: '555-1234'
        ).and_return({ success: true, user: double(:user) })
      end

      it 'filters out unpermitted parameters' do
        post :create, params: { user: invalid_params }

        expect(users_api).to have_received(:create_user).with(
          username: 'testuser',
          password: 'password123',
          email: 'test@example.com',
          phone_number: '555-1234'
        )
      end
    end
  end

  describe '#success' do
    it 'renders the success page' do
      get :success

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:success)
    end
  end

  describe '#login' do
    it 'renders the login form' do
      get :login

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:login)
    end
  end

  describe '#authenticate' do
    let(:users_api) { double(:users_api) }
    let(:login_params) do
      {
        username: 'testuser',
        password: 'password123'
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
        allow(users_api).to receive(:authenticate_user).with(
          username: login_params[:username],
          password: login_params[:password]
        ).and_return(successful_result)
      end

      it 'sets user session and redirects to profile' do
        post :authenticate, params: { user: login_params }

        expect(session[:user_id]).to eq('user-123')
        expect(response).to redirect_to(profile_users_path)
        expect(flash[:notice]).to eq('Successfully logged in!')
      end

      it 'calls UsersApi with correct parameters' do
        post :authenticate, params: { user: login_params }

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
        allow(users_api).to receive(:authenticate_user).with(
          username: login_params[:username],
          password: login_params[:password]
        ).and_return(failed_result)
      end

      it 'renders login template with errors' do
        post :authenticate, params: { user: login_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:login)
        expect(assigns(:errors)).to eq([ 'Invalid username or password' ])
      end

      it 'does not set user session' do
        post :authenticate, params: { user: login_params }

        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe '#profile' do
    let(:users_api) { double(:users_api) }
    let(:user_profile_data) do
      {
        username: 'testuser',
        email: 'test@example.com',
        phone_number: '+1234567890',
        created_at: Time.new(2023, 1, 15)
      }
    end

    before do
      allow(UsersApi).to receive(:new).and_return(users_api)
    end

    context 'when user is logged in' do
      before do
        session[:user_id] = 'user-123'
        allow(users_api).to receive(:get_user_profile).with(user_id: 'user-123').and_return({
          success: true,
          profile: user_profile_data,
          errors: []
        })
      end

      it 'renders the profile page with user data' do
        get :profile

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:profile)
        expect(assigns(:user_data)).to eq(user_profile_data)
      end

      it 'calls UsersApi with correct user ID' do
        get :profile

        expect(users_api).to have_received(:get_user_profile).with(user_id: 'user-123')
      end
    end

    context 'when user profile cannot be loaded' do
      before do
        session[:user_id] = 'user-123'
        allow(users_api).to receive(:get_user_profile).with(user_id: 'user-123').and_return({
          success: false,
          profile: nil,
          errors: [ 'User not found' ]
        })
      end

      it 'redirects to login page with alert' do
        get :profile

        expect(response).to redirect_to(login_users_path)
        expect(flash[:alert]).to eq('Unable to load profile. Please log in again.')
      end
    end

    context 'when user is not logged in' do
      before do
        session[:user_id] = nil
      end

      it 'redirects to login page with alert' do
        get :profile

        expect(response).to redirect_to(login_users_path)
        expect(flash[:alert]).to eq('Please log in to view your profile')
      end

      it 'does not call UsersApi' do
        allow(users_api).to receive(:get_user_profile)

        get :profile

        expect(users_api).not_to have_received(:get_user_profile)
      end
    end
  end

  describe '#logout' do
    before do
      session[:user_id] = 'user-123'
    end

    it 'clears the user session and redirects to root' do
      delete :logout

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq('Successfully logged out!')
    end
  end

  describe 'private methods' do
    let(:controller_instance) { described_class.new }

    describe '#user_params' do
      let(:mock_params) do
        ActionController::Parameters.new(
          user: {
            username: 'testuser',
            password: 'password123',
            email: 'test@example.com',
            phone_number: '555-1234',
            admin: true,  # This should be filtered out
            role: 'superuser'  # This should also be filtered out
          }
        )
      end

      before do
        allow(controller_instance).to receive(:params).and_return(mock_params)
      end

      it 'permits only allowed parameters' do
        result = controller_instance.send(:user_params)

        expect(result.keys).to contain_exactly('username', 'password', 'email', 'phone_number')
        expect(result['username']).to eq('testuser')
        expect(result['password']).to eq('password123')
        expect(result['email']).to eq('test@example.com')
        expect(result['phone_number']).to eq('555-1234')
        expect(result.key?('admin')).to be false
        expect(result.key?('role')).to be false
      end
    end

    describe '#login_params' do
      let(:login_params_data) do
        ActionController::Parameters.new(
          user: {
            username: 'testuser',
            password: 'password123',
            extra_param: 'should_be_filtered'
          }
        )
      end

      before do
        allow(controller_instance).to receive(:params).and_return(login_params_data)
      end

      it 'permits only username and password' do
        result = controller_instance.send(:login_params)

        expect(result.keys).to contain_exactly('username', 'password')
        expect(result['username']).to eq('testuser')
        expect(result['password']).to eq('password123')
        expect(result.key?('extra_param')).to be false
      end
    end

    describe '#logged_in?' do
      context 'when user_id is present in session' do
        before do
          allow(controller_instance).to receive(:session).and_return({ user_id: 'user-123' })
        end

        it 'returns true' do
          expect(controller_instance.send(:logged_in?)).to be true
        end
      end

      context 'when user_id is not in session' do
        before do
          allow(controller_instance).to receive(:session).and_return({})
        end

        it 'returns false' do
          expect(controller_instance.send(:logged_in?)).to be false
        end
      end
    end

    describe '#current_user_id' do
      before do
        allow(controller_instance).to receive(:session).and_return({ user_id: 'user-123' })
      end

      it 'returns the user_id from session' do
        expect(controller_instance.send(:current_user_id)).to eq('user-123')
      end
    end
  end
end
