require 'rails_helper'

RSpec.describe UserContactPreferenceUpdateService, type: :service do
  let(:user_contact_preference_model) { double(:user_contact_preference_model) }
  let(:logger) { double(:logger) }
  let(:contact_preference) { double(:contact_preference) }
  let(:user_id) { 'user123' }

  let(:service) do
    described_class.new(
      user_contact_preference_model: user_contact_preference_model,
      logger: logger
    )
  end

  describe '#call' do
    context 'when contact preference exists' do
      before do
        allow(user_contact_preference_model).to receive(:find_by).with(user_id: user_id).and_return(contact_preference)
      end

      context 'when update is successful' do
        let(:update_params) do
          {
            user_id: user_id,
            email: 'new@example.com',
            phone_number: '+1234567890',
            email_notifications_enabled: false,
            phone_notifications_enabled: true
          }
        end

        before do
          allow(contact_preference).to receive(:update).and_return(true)
        end

        it 'updates the contact preference with all provided attributes' do
          expected_attributes = {
            email: 'new@example.com',
            phone_number: '+1234567890',
            email_notifications_enabled: false,
            phone_notifications_enabled: true
          }

          service.call(**update_params)

          expect(contact_preference).to have_received(:update).with(expected_attributes)
        end

        it 'returns the contact preference with no errors' do
          contact_preference, errors = service.call(**update_params)

          expect(contact_preference).to eq(contact_preference)
          expect(errors).to eq([])
        end

        context 'with partial updates' do
          it 'only updates provided email' do
            service.call(user_id: user_id, email: 'new@example.com')

            expect(contact_preference).to have_received(:update).with({ email: 'new@example.com' })
          end

          it 'only updates provided phone number' do
            service.call(user_id: user_id, phone_number: '+1234567890')

            expect(contact_preference).to have_received(:update).with({ phone_number: '+1234567890' })
          end

          it 'only updates provided email notifications setting' do
            service.call(user_id: user_id, email_notifications_enabled: false)

            expect(contact_preference).to have_received(:update).with({ email_notifications_enabled: false })
          end

          it 'only updates provided phone notifications setting' do
            service.call(user_id: user_id, phone_notifications_enabled: true)

            expect(contact_preference).to have_received(:update).with({ phone_notifications_enabled: true })
          end
        end

        context 'filtering out nil values' do
          it 'does not include nil email in update attributes' do
            service.call(user_id: user_id, email: nil, phone_number: '+1234567890')

            expect(contact_preference).to have_received(:update).with({ phone_number: '+1234567890' })
          end

          it 'does not include nil phone_number in update attributes' do
            service.call(user_id: user_id, email: 'new@example.com', phone_number: nil)

            expect(contact_preference).to have_received(:update).with({ email: 'new@example.com' })
          end

          it 'includes false values for boolean fields' do
            service.call(user_id: user_id, email_notifications_enabled: false, phone_notifications_enabled: false)

            expect(contact_preference).to have_received(:update).with({
              email_notifications_enabled: false,
              phone_notifications_enabled: false
            })
          end

          it 'includes true values for boolean fields' do
            service.call(user_id: user_id, email_notifications_enabled: true, phone_notifications_enabled: true)

            expect(contact_preference).to have_received(:update).with({
              email_notifications_enabled: true,
              phone_notifications_enabled: true
            })
          end
        end
      end

      context 'when update fails' do
        let(:errors_double) { double(:errors) }
        let(:error_messages) { [ 'Email is invalid', 'Phone number is invalid' ] }

        before do
          allow(contact_preference).to receive(:update).and_return(false)
          allow(contact_preference).to receive(:errors).and_return(errors_double)
          allow(errors_double).to receive(:full_messages).and_return(error_messages)
        end

        it 'returns nil contact preference with validation errors' do
          contact_preference_result, errors = service.call(
            user_id: user_id,
            email: 'invalid-email',
            phone_number: 'invalid-phone'
          )

          expect(contact_preference_result).to be_nil
          expect(errors).to eq(error_messages)
        end
      end
    end

    context 'when contact preference does not exist' do
      before do
        allow(user_contact_preference_model).to receive(:find_by).with(user_id: user_id).and_return(nil)
      end

      it 'returns nil contact preference with error message' do
        contact_preference, errors = service.call(user_id: user_id, email: 'new@example.com')

        expect(contact_preference).to be_nil
        expect(errors).to eq([ "Contact preference not found for user #{user_id}" ])
      end

      it 'does not attempt to update anything' do
        service.call(user_id: user_id, email: 'new@example.com')

        # No update should be attempted since contact preference doesn't exist
        expect(user_contact_preference_model).to have_received(:find_by).once
      end
    end
  end

  describe 'dependency injection' do
    it 'uses default dependencies when none provided' do
      service = described_class.new

      expect(service).to be_an_instance_of(described_class)
    end

    it 'accepts custom dependencies' do
      custom_model = double(:custom_model)
      custom_logger = double(:custom_logger)

      service = described_class.new(
        user_contact_preference_model: custom_model,
        logger: custom_logger
      )

      expect(service).to be_an_instance_of(described_class)
    end
  end

  describe 'private methods' do
    describe '#find_contact_preference' do
      it 'finds contact preference by user_id' do
        allow(user_contact_preference_model).to receive(:find_by).with(user_id: user_id).and_return(contact_preference)

        result = service.send(:find_contact_preference, user_id: user_id)

        expect(result).to eq(contact_preference)
        expect(user_contact_preference_model).to have_received(:find_by).with(user_id: user_id)
      end
    end

    describe '#build_update_attributes' do
      it 'builds attributes hash with all provided values' do
        attributes = service.send(:build_update_attributes,
          email: 'test@example.com',
          phone_number: '+1234567890',
          email_notifications_enabled: true,
          phone_notifications_enabled: false
        )

        expect(attributes).to eq({
          email: 'test@example.com',
          phone_number: '+1234567890',
          email_notifications_enabled: true,
          phone_notifications_enabled: false
        })
      end

      it 'excludes nil values' do
        attributes = service.send(:build_update_attributes,
          email: 'test@example.com',
          phone_number: nil,
          email_notifications_enabled: true,
          phone_notifications_enabled: nil
        )

        expect(attributes).to eq({
          email: 'test@example.com',
          email_notifications_enabled: true
        })
      end

      it 'includes false boolean values' do
        attributes = service.send(:build_update_attributes,
          email: nil,
          phone_number: nil,
          email_notifications_enabled: false,
          phone_notifications_enabled: false
        )

        expect(attributes).to eq({
          email_notifications_enabled: false,
          phone_notifications_enabled: false
        })
      end
    end

    describe '#update_contact_preference' do
      context 'when update succeeds' do
        before do
          allow(contact_preference).to receive(:update).and_return(true)
        end

        it 'returns contact preference with empty errors' do
          result = service.send(:update_contact_preference,
            contact_preference: contact_preference,
            update_attributes: { email: 'test@example.com' }
          )

          expect(result).to eq([ contact_preference, [] ])
        end
      end

      context 'when update fails' do
        let(:errors_double) { double(:errors) }
        let(:error_messages) { [ 'Email is invalid' ] }

        before do
          allow(contact_preference).to receive(:update).and_return(false)
          allow(contact_preference).to receive(:errors).and_return(errors_double)
          allow(errors_double).to receive(:full_messages).and_return(error_messages)
        end

        it 'returns nil contact preference with error messages' do
          result = service.send(:update_contact_preference,
            contact_preference: contact_preference,
            update_attributes: { email: 'invalid-email' }
          )

          expect(result).to eq([ nil, error_messages ])
        end
      end
    end
  end
end
