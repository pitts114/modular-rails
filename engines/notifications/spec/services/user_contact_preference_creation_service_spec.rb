require 'rails_helper'

RSpec.describe UserContactPreferenceCreationService do
  let(:user_contact_preference_model) { double(:user_contact_preference_model) }
  let(:email_service) { double(:email_service) }
  let(:logger) { double(:logger) }
  let(:service) do
    UserContactPreferenceCreationService.new(
      user_contact_preference_model: user_contact_preference_model,
      email_service: email_service,
      logger: logger
    )
  end

  let(:user_id) { SecureRandom.uuid }
  let(:email) { 'test@example.com' }
  let(:phone_number) { '+1234567890' }

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
      end

      it 'creates a contact preference with correct parameters' do
        expect(user_contact_preference_model).to receive(:new)
          .with(
            user_id: user_id,
            email: email,
            phone_number: phone_number
          )
          .and_return(contact_preference)

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end

      it 'saves the contact preference' do
        expect(contact_preference).to receive(:save)

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end

      it 'sends a welcome email' do
        expect(email_service).to receive(:send_welcome_email)
          .with(email: email, user_id: user_id)

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end

      it 'logs the welcome email sending' do
        expect(logger).to receive(:info)
          .with("Welcome email sent to #{email} for user #{user_id}")

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end

      it 'returns success result with contact preference' do
        contact_preference, errors = service.call(user_id: user_id, email: email, phone_number: phone_number)

        expect(contact_preference).to eq(contact_preference)
        expect(errors).to eq([])
      end

      context 'when phone number is nil' do
        it 'creates contact preference without phone number' do
          expect(user_contact_preference_model).to receive(:new)
            .with(
              user_id: user_id,
              email: email,
              phone_number: nil
            )
            .and_return(contact_preference)

          service.call(user_id: user_id, email: email, phone_number: nil)
        end

        it 'still sends welcome email' do
          expect(email_service).to receive(:send_welcome_email)
            .with(email: email, user_id: user_id)

          service.call(user_id: user_id, email: email, phone_number: nil)
        end
      end

      context 'when phone number is not provided as parameter' do
        it 'defaults phone_number to nil' do
          expect(user_contact_preference_model).to receive(:new)
            .with(
              user_id: user_id,
              email: email,
              phone_number: nil
            )
            .and_return(contact_preference)

          service.call(user_id: user_id, email: email)
        end
      end
    end

    context 'when contact preference creation fails' do
      let(:errors) { double(:errors, full_messages: [ 'Email is invalid', 'User must exist' ]) }

      before do
        allow(contact_preference).to receive(:persisted?).and_return(false)
        allow(contact_preference).to receive(:errors).and_return(errors)
      end

      it 'does not send welcome email' do
        expect(email_service).not_to receive(:send_welcome_email)

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end

      it 'does not log welcome email sending' do
        expect(logger).not_to receive(:info)

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end

      it 'returns failure result with errors' do
        contact_preference_result, errors = service.call(user_id: user_id, email: email, phone_number: phone_number)

        expect(contact_preference_result).to be_nil
        expect(errors).to eq([ 'Email is invalid', 'User must exist' ])
      end
    end

    context 'when welcome email sending fails' do
      let(:email_error) { StandardError.new('SMTP server unavailable') }

      before do
        allow(contact_preference).to receive(:persisted?).and_return(true)
        allow(email_service).to receive(:send_welcome_email).and_raise(email_error)
      end

      it 'logs the email error' do
        expect(logger).to receive(:error)
          .with("Failed to send welcome email to #{email}: SMTP server unavailable")

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end

      it 'still returns success result since contact preference was created' do
        contact_preference, errors = service.call(user_id: user_id, email: email, phone_number: phone_number)

        expect(contact_preference).to eq(contact_preference)
        expect(errors).to eq([])
      end

      it 'does not log successful email sending' do
        expect(logger).not_to receive(:info)
          .with("Welcome email sent to #{email} for user #{user_id}")

        service.call(user_id: user_id, email: email, phone_number: phone_number)
      end
    end
  end

  describe 'dependency injection' do
    it 'uses default dependencies when none provided' do
      service = UserContactPreferenceCreationService.new

      expect(service.instance_variable_get(:@user_contact_preference_model)).to eq(UserContactPreference)
      expect(service.instance_variable_get(:@email_service)).to be_a(MockEmailService)
      expect(service.instance_variable_get(:@logger)).to eq(Rails.logger)
    end

    it 'accepts custom dependencies' do
      custom_model = double(:custom_model)
      custom_email_service = double(:custom_email_service)
      custom_logger = double(:custom_logger)

      service = UserContactPreferenceCreationService.new(
        user_contact_preference_model: custom_model,
        email_service: custom_email_service,
        logger: custom_logger
      )

      expect(service.instance_variable_get(:@user_contact_preference_model)).to eq(custom_model)
      expect(service.instance_variable_get(:@email_service)).to eq(custom_email_service)
      expect(service.instance_variable_get(:@logger)).to eq(custom_logger)
    end
  end

  describe 'private methods' do
    describe '#create_contact_preference' do
      it 'creates and saves a new contact preference' do
        contact_preference = double(:contact_preference)

        expect(user_contact_preference_model).to receive(:new)
          .with(
            user_id: user_id,
            email: email,
            phone_number: phone_number
          )
          .and_return(contact_preference)

        expect(contact_preference).to receive(:save)

        service.send(:create_contact_preference,
          user_id: user_id,
          email: email,
          phone_number: phone_number
        )
      end
    end

    describe '#send_welcome_email' do
      before do
        allow(logger).to receive(:info)
        allow(logger).to receive(:error)
      end

      context 'when email sending succeeds' do
        before do
          allow(email_service).to receive(:send_welcome_email)
        end

        it 'calls the email service with correct parameters' do
          expect(email_service).to receive(:send_welcome_email)
            .with(email: email, user_id: user_id)

          service.send(:send_welcome_email, email: email, user_id: user_id)
        end

        it 'logs successful email sending' do
          expect(logger).to receive(:info)
            .with("Welcome email sent to #{email} for user #{user_id}")

          service.send(:send_welcome_email, email: email, user_id: user_id)
        end
      end

      context 'when email sending fails' do
        let(:email_error) { StandardError.new('Connection timeout') }

        before do
          allow(email_service).to receive(:send_welcome_email).and_raise(email_error)
        end

        it 'logs the error' do
          expect(logger).to receive(:error)
            .with("Failed to send welcome email to #{email}: Connection timeout")

          service.send(:send_welcome_email, email: email, user_id: user_id)
        end

        it 'does not re-raise the error' do
          expect {
            service.send(:send_welcome_email, email: email, user_id: user_id)
          }.not_to raise_error
        end
      end
    end
  end

  describe 'error handling edge cases' do
    let(:contact_preference) { double(:contact_preference) }

    before do
      allow(user_contact_preference_model).to receive(:new).and_return(contact_preference)
      allow(contact_preference).to receive(:save)
    end

    context 'when contact preference is persisted but errors exist' do
      let(:errors) { double(:errors, full_messages: [ 'Warning: Phone number format unusual' ]) }

      before do
        allow(contact_preference).to receive(:persisted?).and_return(true)
        allow(contact_preference).to receive(:errors).and_return(errors)
        allow(email_service).to receive(:send_welcome_email)
        allow(logger).to receive(:info)
      end

      it 'still returns success and sends welcome email' do
        _, errors = service.call(user_id: user_id, email: email, phone_number: phone_number)

        expect(errors).to eq([])
        expect(email_service).to have_received(:send_welcome_email)
      end
    end

    context 'with different email service error types' do
      before do
        allow(contact_preference).to receive(:persisted?).and_return(true)
      end

      [
        StandardError.new('Generic error'),
        RuntimeError.new('Runtime error'),
        SocketError.new('Network error')
      ].each do |error|
        it "handles #{error.class} gracefully" do
          allow(email_service).to receive(:send_welcome_email).and_raise(error)

          expect(logger).to receive(:error)
            .with("Failed to send welcome email to #{email}: #{error.message}")

          expect {
            service.call(user_id: user_id, email: email, phone_number: phone_number)
          }.not_to raise_error
        end
      end
    end
  end
end
