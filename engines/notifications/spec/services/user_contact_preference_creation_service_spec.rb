require 'rails_helper'

RSpec.describe UserContactPreferenceCreationService do
  let(:user_contact_preference_model) { double(:user_contact_preference_model) }
  let(:email_service) { double(:email_service) }
  let(:users_api) { double(:users_api) }
  let(:logger) { double(:logger) }
  let(:service) do
    UserContactPreferenceCreationService.new(
      user_contact_preference_model: user_contact_preference_model,
      email_service: email_service,
      users_api: users_api,
      logger: logger
    )
  end

  let(:user_id) { SecureRandom.uuid }
  let(:email) { 'test@example.com' }
  let(:user_profile) { double(:user_profile, email: email, phone_number: '+1234567890') }

  describe '#call' do
    let(:contact_preference) { double(:contact_preference) }

    before do
      allow(user_contact_preference_model).to receive(:new).and_return(contact_preference)
      allow(contact_preference).to receive(:save)
      allow(logger).to receive(:info)
      allow(logger).to receive(:error)
    end

    context 'when contact preference is successfully created' do
      before do
        allow(contact_preference).to receive(:persisted?).and_return(true)
        allow(email_service).to receive(:send_welcome_email)
        allow(users_api).to receive(:get_user_profile).and_return({ success: true, profile: user_profile })
      end

      it 'creates a contact preference with user_id only' do
        expect(user_contact_preference_model).to receive(:new)
          .with(user_id: user_id)
          .and_return(contact_preference)

        service.call(user_id: user_id)
      end

      it 'saves the contact preference' do
        expect(contact_preference).to receive(:save)

        service.call(user_id: user_id)
      end

      it 'fetches user profile from Users API' do
        expect(users_api).to receive(:get_user_profile)
          .with(user_id: user_id)

        service.call(user_id: user_id)
      end

      it 'sends a welcome email with fetched email' do
        expect(email_service).to receive(:send_welcome_email)
          .with(email: email, user_id: user_id)

        service.call(user_id: user_id)
      end

      it 'logs the welcome email sending' do
        expect(logger).to receive(:info)
          .with("Welcome email sent to #{email} for user #{user_id}")

        service.call(user_id: user_id)
      end

      it 'returns success result with contact preference' do
        result_preference, errors = service.call(user_id: user_id)

        expect(result_preference).to eq(contact_preference)
        expect(errors).to eq([])
      end
    end

    context 'when contact preference creation fails' do
      let(:errors) { double(:errors, full_messages: [ 'User must exist' ]) }

      before do
        allow(contact_preference).to receive(:persisted?).and_return(false)
        allow(contact_preference).to receive(:errors).and_return(errors)
      end

      it 'does not fetch user profile' do
        expect(users_api).not_to receive(:get_user_profile)

        service.call(user_id: user_id)
      end

      it 'does not send welcome email' do
        expect(email_service).not_to receive(:send_welcome_email)

        service.call(user_id: user_id)
      end

      it 'returns failure result with errors' do
        contact_preference_result, errors = service.call(user_id: user_id)

        expect(contact_preference_result).to be_nil
        expect(errors).to eq([ 'User must exist' ])
      end
    end

    context 'when fetching user profile fails' do
      before do
        allow(contact_preference).to receive(:persisted?).and_return(true)
        allow(users_api).to receive(:get_user_profile).and_return({ success: false, errors: [ 'User not found' ] })
      end

      it 'logs the error' do
        expect(logger).to receive(:error)
          .with("Failed to fetch user profile for welcome email: User not found")

        service.call(user_id: user_id)
      end

      it 'still returns success since contact preference was created' do
        result_preference, errors = service.call(user_id: user_id)

        expect(result_preference).to eq(contact_preference)
        expect(errors).to eq([])
      end
    end

    context 'when welcome email sending fails' do
      let(:email_error) { StandardError.new('SMTP server unavailable') }

      before do
        allow(contact_preference).to receive(:persisted?).and_return(true)
        allow(users_api).to receive(:get_user_profile).and_return({ success: true, profile: user_profile })
        allow(email_service).to receive(:send_welcome_email).and_raise(email_error)
      end

      it 'logs the email error' do
        expect(logger).to receive(:error)
          .with("Failed to send welcome email: SMTP server unavailable")

        service.call(user_id: user_id)
      end

      it 'still returns success result since contact preference was created' do
        result_preference, errors = service.call(user_id: user_id)

        expect(result_preference).to eq(contact_preference)
        expect(errors).to eq([])
      end
    end
  end

  describe 'dependency injection' do
    it 'uses default dependencies when none provided' do
      service = UserContactPreferenceCreationService.new

      expect(service.instance_variable_get(:@user_contact_preference_model)).to eq(UserContactPreference)
      expect(service.instance_variable_get(:@email_service)).to be_a(MockEmailService)
      expect(service.instance_variable_get(:@users_api)).to be_a(UsersApi)
      expect(service.instance_variable_get(:@logger)).to eq(Rails.logger)
    end

    it 'accepts custom dependencies' do
      custom_model = double(:custom_model)
      custom_email_service = double(:custom_email_service)
      custom_users_api = double(:custom_users_api)
      custom_logger = double(:custom_logger)

      service = UserContactPreferenceCreationService.new(
        user_contact_preference_model: custom_model,
        email_service: custom_email_service,
        users_api: custom_users_api,
        logger: custom_logger
      )

      expect(service.instance_variable_get(:@user_contact_preference_model)).to eq(custom_model)
      expect(service.instance_variable_get(:@email_service)).to eq(custom_email_service)
      expect(service.instance_variable_get(:@users_api)).to eq(custom_users_api)
      expect(service.instance_variable_get(:@logger)).to eq(custom_logger)
    end
  end
end
