require 'rails_helper'

RSpec.describe NotificationsApi do
  let(:user_contact_preference_model) { double(:user_contact_preference_model) }
  let(:user_contact_preference_creation_service) { double(:user_contact_preference_creation_service) }
  let(:user_contact_preference_update_service) { double(:user_contact_preference_update_service) }
  let(:logger) { double(:logger) }
  let(:api) do
    NotificationsApi.new(
      user_contact_preference_model: user_contact_preference_model,
      user_contact_preference_creation_service: user_contact_preference_creation_service,
      user_contact_preference_update_service: user_contact_preference_update_service,
      logger: logger
    )
  end

  describe '#create_contact_preference' do
    let(:user_id) { SecureRandom.uuid }
    let(:email) { 'test@example.com' }
    let(:phone_number) { '+1234567890' }

    it 'delegates to the creation service' do
      contact_preference = double(:contact_preference)

      expect(user_contact_preference_creation_service).to receive(:call)
        .with(user_id: user_id, email: email, phone_number: phone_number)
        .and_return([ contact_preference, [] ])

      result = api.create_contact_preference(
        user_id: user_id,
        email: email,
        phone_number: phone_number
      )

      expect(result).to eq({
        success: true,
        contact_preference: contact_preference,
        errors: []
      })
    end

    it 'handles service returning errors' do
      errors = [ 'Email is invalid' ]

      expect(user_contact_preference_creation_service).to receive(:call)
        .with(user_id: user_id, email: email, phone_number: phone_number)
        .and_return([ nil, errors ])

      result = api.create_contact_preference(
        user_id: user_id,
        email: email,
        phone_number: phone_number
      )

      expect(result).to eq({
        success: false,
        contact_preference: nil,
        errors: errors
      })
    end

    it 'handles StandardError exceptions' do
      expect(user_contact_preference_creation_service).to receive(:call)
        .and_raise(StandardError.new('Database connection failed'))

      result = api.create_contact_preference(
        user_id: user_id,
        email: email,
        phone_number: phone_number
      )

      expect(result).to eq({
        success: false,
        contact_preference: nil,
        errors: [ 'An unexpected error occurred: Database connection failed' ]
      })
    end
  end

  describe '#get_contact_preference' do
    let(:user_id) { SecureRandom.uuid }

    context 'when contact preference exists' do
      it 'returns success with the contact preference' do
        contact_preference = double(:contact_preference)

        expect(user_contact_preference_model).to receive(:find_by)
          .with(user_id: user_id)
          .and_return(contact_preference)

        result = api.get_contact_preference(user_id: user_id)

        expect(result).to eq({
          success: true,
          contact_preference: contact_preference,
          errors: []
        })
      end
    end

    context 'when contact preference does not exist' do
      it 'returns failure with error message' do
        expect(user_contact_preference_model).to receive(:find_by)
          .with(user_id: user_id)
          .and_return(nil)

        result = api.get_contact_preference(user_id: user_id)

        expect(result).to eq({
          success: false,
          contact_preference: nil,
          errors: [ "Contact preference not found for user #{user_id}" ]
        })
      end
    end

    context 'when service raises an error' do
      it 'returns failure result with error message' do
        expect(user_contact_preference_model).to receive(:find_by)
          .and_raise(StandardError.new('Database connection failed'))

        result = api.get_contact_preference(user_id: user_id)

        expect(result).to eq({
          success: false,
          contact_preference: nil,
          errors: [ 'An unexpected error occurred: Database connection failed' ]
        })
      end
    end
  end

  describe '#update_contact_preference' do
    let(:user_id) { SecureRandom.uuid }
    let(:contact_preference) { double(:contact_preference) }

    it 'delegates to the update service' do
      update_params = {
        user_id: user_id,
        email: 'new@example.com',
        phone_number: '+9876543210',
        email_notifications_enabled: false,
        phone_notifications_enabled: true
      }

      expect(user_contact_preference_update_service).to receive(:call)
        .with(**update_params)
        .and_return([ contact_preference, [] ])

      result = api.update_contact_preference(**update_params)

      expect(result).to eq({
        success: true,
        contact_preference: contact_preference,
        errors: []
      })
    end

    it 'handles service returning errors' do
      error_messages = [ 'Email is invalid', 'Phone number is invalid' ]

      expect(user_contact_preference_update_service).to receive(:call)
        .with(
          user_id: user_id,
          email: 'invalid-email',
          phone_number: nil,
          email_notifications_enabled: nil,
          phone_notifications_enabled: nil
        )
        .and_return([ nil, error_messages ])

      result = api.update_contact_preference(user_id: user_id, email: 'invalid-email')

      expect(result).to eq({
        success: false,
        contact_preference: nil,
        errors: error_messages
      })
    end

    it 'handles service returning nil contact preference' do
      error_messages = [ "Contact preference not found for user #{user_id}" ]

      expect(user_contact_preference_update_service).to receive(:call)
        .with(
          user_id: user_id,
          email: 'new@example.com',
          phone_number: nil,
          email_notifications_enabled: nil,
          phone_notifications_enabled: nil
        )
        .and_return([ nil, error_messages ])

      result = api.update_contact_preference(user_id: user_id, email: 'new@example.com')

      expect(result).to eq({
        success: false,
        contact_preference: nil,
        errors: error_messages
      })
    end

    it 'handles StandardError exceptions' do
      expect(user_contact_preference_update_service).to receive(:call)
        .and_raise(StandardError.new('Database connection failed'))

      result = api.update_contact_preference(user_id: user_id, email: 'new@example.com')

      expect(result).to eq({
        success: false,
        contact_preference: nil,
        errors: [ 'An unexpected error occurred: Database connection failed' ]
      })
    end
  end
end
