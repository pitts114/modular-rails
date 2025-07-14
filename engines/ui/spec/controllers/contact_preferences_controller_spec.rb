require 'rails_helper'

RSpec.describe ContactPreferencesController, type: :controller do
  let(:notifications_api) { double(:notifications_api) }
  let(:user_id) { SecureRandom.uuid }

  before do
    allow(NotificationsApi).to receive(:new).and_return(notifications_api)
    # Mock session for authentication
    allow(controller).to receive(:session).and_return({ user_id: user_id })
  end

  describe 'GET #show' do
    context 'when user is logged in' do
      context 'when contact preference exists' do
        it 'assigns contact preference and renders successfully' do
          contact_preference = double(:contact_preference)
          api_result = {
            success: true,
            contact_preference: contact_preference,
            errors: []
          }

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return(api_result)

          get :show

          expect(assigns(:contact_preference)).to eq(contact_preference)
          expect(assigns(:errors)).to be_nil
          expect(response).to have_http_status(:success)
        end
      end

      context 'when contact preference does not exist' do
        it 'assigns errors and sets contact preference to nil' do
          api_result = {
            success: false,
            contact_preference: nil,
            errors: ['Contact preference not found']
          }

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return(api_result)

          get :show

          expect(assigns(:contact_preference)).to be_nil
          expect(assigns(:errors)).to eq(['Contact preference not found'])
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
        it 'assigns contact preference and renders edit form' do
          contact_preference = double(:contact_preference)
          api_result = {
            success: true,
            contact_preference: contact_preference,
            errors: []
          }

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return(api_result)

          get :edit

          expect(assigns(:contact_preference)).to eq(contact_preference)
          expect(response).to have_http_status(:success)
        end
      end

      context 'when contact preference does not exist' do
        it 'redirects to show page with alert' do
          api_result = {
            success: false,
            contact_preference: nil,
            errors: ['Contact preference not found']
          }

          expect(notifications_api).to receive(:get_contact_preference)
            .with(user_id: user_id)
            .and_return(api_result)

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
          contact_preference = double(:contact_preference)
          api_result = {
            success: true,
            contact_preference: contact_preference,
            errors: []
          }

          expect(notifications_api).to receive(:update_contact_preference)
            .with(
              user_id: user_id,
              email: 'new@example.com',
              phone_number: '+1234567890',
              email_notifications_enabled: true,
              phone_notifications_enabled: false
            )
            .and_return(api_result)

          patch :update, params: update_params

          expect(response).to redirect_to(contact_preferences_path)
          expect(flash[:notice]).to eq('Contact preferences updated successfully!')
        end
      end

      context 'when update fails' do
        it 'renders edit form with errors' do
          contact_preference = double(:contact_preference)
          api_result = {
            success: false,
            contact_preference: contact_preference,
            errors: ['Email is invalid']
          }

          expect(notifications_api).to receive(:update_contact_preference)
            .and_return(api_result)

          patch :update, params: update_params

          expect(assigns(:contact_preference)).to eq(contact_preference)
          expect(assigns(:errors)).to eq(['Email is invalid'])
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

      expect(notifications_api).to receive(:update_contact_preference)
        .with(
          user_id: user_id,
          email: 'test@example.com',
          phone_number: nil,
          email_notifications_enabled: true,
          phone_notifications_enabled: false
        )
        .and_return({ success: true, contact_preference: double(:contact_preference), errors: [] })

      patch :update, params: update_params
    end
  end
end
