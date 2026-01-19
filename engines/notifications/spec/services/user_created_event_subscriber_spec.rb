require 'rails_helper'

RSpec.describe UserCreatedEventSubscriber do
  let(:notifications_api) { double(:notifications_api) }
  let(:logger) { double(:logger) }
  let(:subscriber) { described_class.new(notifications_api: notifications_api, logger: logger) }

  # Mock event object that matches ActiveSupport::Notifications structure
  let(:mock_event) do
    double(:event, payload: {
      user_id: 'user123',
      username: 'testuser',
      email: 'test@example.com',
      phone_number: '+1234567890',
      created_at: Time.current
    })
  end

  describe '#initialize' do
    it 'uses default dependencies when none provided' do
      allow(NotificationsApi).to receive(:new).and_return(notifications_api)
      allow(Rails).to receive(:logger).and_return(logger)

      default_subscriber = described_class.new

      expect(NotificationsApi).to have_received(:new)
      expect(Rails).to have_received(:logger)
      expect(default_subscriber).to be_a(described_class)
    end

    it 'accepts custom dependencies' do
      custom_api = double(:custom_api)
      custom_logger = double(:custom_logger)

      subscriber = described_class.new(
        notifications_api: custom_api,
        logger: custom_logger
      )

      expect(subscriber.instance_variable_get(:@notifications_api)).to eq(custom_api)
      expect(subscriber.instance_variable_get(:@logger)).to eq(custom_logger)
    end
  end

  describe '#call' do
    context 'when contact preference creation succeeds' do
      let(:success_result) do
        {
          success: true,
          contact_preference: double(:contact_preference, id: 'pref123'),
          errors: []
        }
      end

      before do
        allow(notifications_api).to receive(:create_contact_preference).and_return(success_result)
        allow(logger).to receive(:info)
      end

      it 'processes the user created event' do
        subscriber.call(mock_event)

        expect(notifications_api).to have_received(:create_contact_preference).with(
          user_id: 'user123'
        )
      end

      it 'logs the event processing start' do
        subscriber.call(mock_event)

        expect(logger).to have_received(:info).with(
          'UserCreatedEventSubscriber: Processing user created event for user user123'
        )
      end

      it 'logs successful contact preference creation' do
        subscriber.call(mock_event)

        expect(logger).to have_received(:info).with(
          'UserCreatedEventSubscriber: Successfully created contact preferences for user user123'
        )
      end

      it 'calls the notifications API with correct parameters' do
        subscriber.call(mock_event)

        expect(notifications_api).to have_received(:create_contact_preference).with(
          user_id: 'user123'
        )
      end

      context 'when phone number is nil in payload' do
        let(:mock_event_no_phone) do
          double(:event, payload: {
            user_id: 'user123',
            username: 'testuser',
            email: 'test@example.com',
            phone_number: nil,
            created_at: Time.current
          })
        end

        it 'still only passes user_id to create_contact_preference' do
          subscriber.call(mock_event_no_phone)

          expect(notifications_api).to have_received(:create_contact_preference).with(
            user_id: 'user123'
          )
        end
      end

      context 'when phone number is not present in payload' do
        let(:mock_event_missing_phone) do
          double(:event, payload: {
            user_id: 'user123',
            username: 'testuser',
            email: 'test@example.com',
            created_at: Time.current
          })
        end

        it 'still only passes user_id to create_contact_preference' do
          subscriber.call(mock_event_missing_phone)

          expect(notifications_api).to have_received(:create_contact_preference).with(
            user_id: 'user123'
          )
        end
      end
    end

    context 'when contact preference creation fails' do
      let(:failure_result) do
        {
          success: false,
          contact_preference: nil,
          errors: [ 'User must exist' ]
        }
      end

      before do
        allow(notifications_api).to receive(:create_contact_preference).and_return(failure_result)
        allow(logger).to receive(:info)
        allow(logger).to receive(:error)
      end

      it 'logs the processing start' do
        subscriber.call(mock_event)

        expect(logger).to have_received(:info).with(
          'UserCreatedEventSubscriber: Processing user created event for user user123'
        )
      end

      it 'logs the failure with error details' do
        subscriber.call(mock_event)

        expect(logger).to have_received(:error).with(
          'UserCreatedEventSubscriber: Failed to create contact preferences for user user123: ["User must exist"]'
        )
      end

      it 'does not log success message' do
        subscriber.call(mock_event)

        expect(logger).not_to have_received(:info).with(
          /Successfully created contact preferences/
        )
      end

      it 'still calls the notifications API' do
        subscriber.call(mock_event)

        expect(notifications_api).to have_received(:create_contact_preference)
      end
    end

    context 'when an exception occurs' do
      let(:error_message) { 'Database connection failed' }
      let(:backtrace) { [ 'line1', 'line2', 'line3' ] }
      let(:exception) { StandardError.new(error_message) }

      before do
        allow(exception).to receive(:backtrace).and_return(backtrace)
        allow(notifications_api).to receive(:create_contact_preference).and_raise(exception)
        allow(logger).to receive(:info)
        allow(logger).to receive(:error)
      end

      it 'logs the error message' do
        subscriber.call(mock_event)

        expect(logger).to have_received(:error).with(
          'UserCreatedEventSubscriber: Error processing user created event: Database connection failed'
        )
      end

      it 'logs the backtrace' do
        subscriber.call(mock_event)

        expect(logger).to have_received(:error).with("line1\nline2\nline3")
      end

      it 'does not re-raise the exception' do
        expect { subscriber.call(mock_event) }.not_to raise_error
      end

      it 'still logs the processing start before the error' do
        subscriber.call(mock_event)

        expect(logger).to have_received(:info).with(
          'UserCreatedEventSubscriber: Processing user created event for user user123'
        )
      end

      context 'with different exception types' do
        [ StandardError, RuntimeError, ArgumentError, NoMethodError ].each do |exception_class|
          it "handles #{exception_class} gracefully" do
            allow(notifications_api).to receive(:create_contact_preference).and_raise(exception_class.new('Test error'))

            expect { subscriber.call(mock_event) }.not_to raise_error
            expect(logger).to have_received(:error).with(
              'UserCreatedEventSubscriber: Error processing user created event: Test error'
            )
          end
        end
      end
    end

    context 'event payload variations' do
      it 'handles minimal payload with only required fields' do
        minimal_event = double(:event, payload: {
          user_id: 'user456',
          email: 'minimal@example.com'
        })

        allow(notifications_api).to receive(:create_contact_preference).and_return({ success: true, contact_preference: double, errors: [] })
        allow(logger).to receive(:info)

        subscriber.call(minimal_event)

        expect(notifications_api).to have_received(:create_contact_preference).with(
          user_id: 'user456'
        )
      end

      it 'handles payload with extra fields' do
        extended_event = double(:event, payload: {
          user_id: 'user789',
          username: 'extendeduser',
          email: 'extended@example.com',
          phone_number: '+9876543210',
          created_at: Time.current,
          extra_field: 'ignored',
          another_field: 123
        })

        allow(notifications_api).to receive(:create_contact_preference).and_return({ success: true, contact_preference: double, errors: [] })
        allow(logger).to receive(:info)

        subscriber.call(extended_event)

        expect(notifications_api).to have_received(:create_contact_preference).with(
          user_id: 'user789'
        )
      end

      it 'handles empty payload gracefully' do
        empty_event = double(:event, payload: {})

        allow(notifications_api).to receive(:create_contact_preference).and_return({ success: true, contact_preference: double, errors: [] })
        allow(logger).to receive(:info)

        subscriber.call(empty_event)

        expect(notifications_api).to have_received(:create_contact_preference).with(
          user_id: nil
        )
      end
    end
  end

  describe 'logging behavior' do
    before do
      allow(notifications_api).to receive(:create_contact_preference).and_return({
        success: true,
        contact_preference: double,
        errors: []
      })
      allow(logger).to receive(:info)
    end

    it 'logs with consistent prefix for identification' do
      subscriber.call(mock_event)

      expect(logger).to have_received(:info).with(
        /^UserCreatedEventSubscriber: Processing/
      ).once

      expect(logger).to have_received(:info).with(
        /^UserCreatedEventSubscriber: Successfully created/
      ).once
    end

    it 'includes user ID in all log messages for traceability' do
      subscriber.call(mock_event)

      expect(logger).to have_received(:info).with(
        /user user123/
      ).twice
    end
  end

  describe 'integration with notifications API' do
    it 'passes through only user_id correctly' do
      api_spy = spy(:notifications_api)
      allow(api_spy).to receive(:create_contact_preference).and_return({
        success: true,
        contact_preference: double,
        errors: []
      })
      allow(logger).to receive(:info)

      subscriber_with_spy = described_class.new(notifications_api: api_spy, logger: logger)

      subscriber_with_spy.call(mock_event)

      expect(api_spy).to have_received(:create_contact_preference).with(
        user_id: 'user123'
      ).once
    end

    it 'handles API response structure correctly' do
      allow(notifications_api).to receive(:create_contact_preference).and_return({
        success: true,
        contact_preference: double(:contact_preference, id: 'pref456'),
        errors: [],
        extra_field: 'ignored'
      })
      allow(logger).to receive(:info)

      expect { subscriber.call(mock_event) }.not_to raise_error
      expect(logger).to have_received(:info).with(/Successfully created/)
    end
  end
end
