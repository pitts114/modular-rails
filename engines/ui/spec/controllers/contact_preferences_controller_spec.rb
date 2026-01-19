require 'rails_helper'

RSpec.describe ContactPreferencesController, type: :controller do
  let(:users_api) { double(:users_api) }
  let(:notifications_api) { double(:notifications_api) }
  let(:user_id) { SecureRandom.uuid }

  before do
    allow(UsersApi).to receive(:new).and_return(users_api)
    allow(NotificationsApi).to receive(:new).and_return(notifications_api)
    # Mock session for authentication
    allow(controller).to receive(:session).and_return({ user_id: user_id })
  end

  describe 'GET #show' do
    context 'when user is logged in' do
      context 'when contact preference exists' do
        it 'assigns profile and contact preference and renders successfully' do
          profile = double(:profile, email: 'test@example.com', phone_number: '+1234567890')
          contact_preference = double(:contact_preference, email_notifications_enabled: true, phone_notifications_enabled: true)

          expect(users_api).to receive(:get_user_profile)
            .with(user_id: user_id)
            .and_return({ success: true, profile: profile, errors: [] })

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return({ success: true, contact_preference: contact_preference, errors: [] })

          get :show

          expect(assigns(:profile)).to eq(profile)
          expect(assigns(:contact_preference)).to eq(contact_preference)
          expect(assigns(:errors)).to be_nil
          expect(response).to have_http_status(:success)
        end
      end

      context 'when contact preference does not exist' do
        it 'assigns errors and sets profile and contact preference to nil' do
          expect(users_api).to receive(:get_user_profile)
            .with(user_id: user_id)
            .and_return({ success: false, profile: nil, errors: [ 'User not found' ] })

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return({ success: false, contact_preference: nil, errors: [ 'Contact preference not found' ] })

          get :show

          expect(assigns(:profile)).to be_nil
          expect(assigns(:contact_preference)).to be_nil
          expect(assigns(:errors)).to include('User not found')
          expect(assigns(:errors)).to include('Contact preference not found')
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'when user is not logged in' do
      before do
        allow(controller).to receive(:session).and_return({})
      end

      it 'redirects to login page' do
        get :show
        expect(response).to redirect_to(login_users_path)
        expect(flash[:alert]).to eq('Please log in to view your contact preferences')
      end
    end
  end

  describe 'GET #edit' do
    context 'when user is logged in' do
      context 'when contact preference exists' do
        it 'assigns profile and contact preference and renders edit form' do
          profile = double(:profile, email: 'test@example.com', phone_number: '+1234567890')
          contact_preference = double(:contact_preference, email_notifications_enabled: true, phone_notifications_enabled: true)

          expect(users_api).to receive(:get_user_profile)
            .with(user_id: user_id)
            .and_return({ success: true, profile: profile, errors: [] })

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return({ success: true, contact_preference: contact_preference, errors: [] })

          get :edit

          expect(assigns(:profile)).to eq(profile)
          expect(assigns(:contact_preference)).to eq(contact_preference)
          expect(response).to have_http_status(:success)
        end
      end

      context 'when contact preference does not exist' do
        it 'redirects to show page with alert' do
          expect(users_api).to receive(:get_user_profile)
            .with(user_id: user_id)
            .and_return({ success: false, profile: nil, errors: [ 'User not found' ] })

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return({ success: false, contact_preference: nil, errors: [ 'Contact preference not found' ] })

          get :edit

          expect(response).to redirect_to(contact_preferences_path)
          expect(flash[:alert]).to eq('Contact preferences not found')
        end
      end
    end

    context 'when user is not logged in' do
      before do
        allow(controller).to receive(:session).and_return({})
      end

      it 'redirects to login page' do
        get :edit
        expect(response).to redirect_to(login_users_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      {
        contact_preference: {
          email: 'new@example.com',
          phone_number: '+1234567890',
          email_notifications_enabled: '1',
          phone_notifications_enabled: '0'
        }
      }
    end

    context 'when user is logged in' do
      context 'when update is successful' do
        it 'redirects to show page with success notice' do
          user = double(:user)
          contact_preference = double(:contact_preference)

          expect(users_api).to receive(:update_user_profile)
            .with(
              user_id: user_id,
              email: 'new@example.com',
              phone_number: '+1234567890'
            )
            .and_return({ success: true, user: user, errors: [] })

          expect(notifications_api).to receive(:update_contact_preference)
            .with(
              user_id: user_id,
              email_notifications_enabled: true,
              phone_notifications_enabled: false
            )
            .and_return({ success: true, contact_preference: contact_preference, errors: [] })

          patch :update, params: update_params

          expect(response).to redirect_to(contact_preferences_path)
          expect(flash[:notice]).to eq('Contact preferences updated successfully!')
        end
      end

      context 'when update fails' do
        it 'renders edit form with errors' do
          profile = double(:profile, email: 'test@example.com', phone_number: '+1234567890')
          contact_preference = double(:contact_preference, email_notifications_enabled: true, phone_notifications_enabled: true)

          expect(users_api).to receive(:update_user_profile)
            .and_return({ success: false, user: nil, errors: [ 'Email is invalid' ] })

          expect(notifications_api).to receive(:update_contact_preference)
            .and_return({ success: true, contact_preference: contact_preference, errors: [] })

          # Re-fetch for display on failure
          expect(users_api).to receive(:get_user_profile)
            .with(user_id: user_id)
            .and_return({ success: true, profile: profile, errors: [] })

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return({ success: true, contact_preference: contact_preference, errors: [] })

          patch :update, params: update_params

          expect(assigns(:profile)).to eq(profile)
          expect(assigns(:contact_preference)).to eq(contact_preference)
          expect(assigns(:errors)).to eq([ 'Email is invalid' ])
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'when user is not logged in' do
      before do
        allow(controller).to receive(:session).and_return({})
      end

      it 'redirects to login page' do
        patch :update, params: update_params
        expect(response).to redirect_to(login_users_path)
      end
    end
  end

  describe 'parameter handling' do
    it 'converts checkbox string values to booleans' do
      update_params = {
        contact_preference: {
          email: 'test@example.com',
          email_notifications_enabled: '1',
          phone_notifications_enabled: '0'
        }
      }

      user = double(:user)
      contact_preference = double(:contact_preference)

      expect(users_api).to receive(:update_user_profile)
        .with(
          user_id: user_id,
          email: 'test@example.com',
          phone_number: nil
        )
        .and_return({ success: true, user: user, errors: [] })

      expect(notifications_api).to receive(:update_contact_preference)
        .with(
          user_id: user_id,
          email_notifications_enabled: true,
          phone_notifications_enabled: false
        )
        .and_return({ success: true, contact_preference: contact_preference, errors: [] })

      patch :update, params: update_params
    end
  end
end
