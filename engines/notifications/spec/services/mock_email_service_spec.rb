require 'rails_helper'

RSpec.describe MockEmailService do
  let(:logger) { double(:logger) }
  let(:service) { MockEmailService.new(logger: logger) }
  let(:email) { 'test@example.com' }
  let(:user_id) { SecureRandom.uuid }

  before do
    allow(logger).to receive(:info)
    # Mock sleep to make tests faster
    allow(service).to receive(:sleep)
  end

  describe '#initialize' do
    it 'uses Rails.logger as default logger' do
      service = MockEmailService.new
      expect(service.instance_variable_get(:@logger)).to eq(Rails.logger)
    end

    it 'accepts custom logger' do
      custom_logger = double(:custom_logger)
      service = MockEmailService.new(logger: custom_logger)
      expect(service.instance_variable_get(:@logger)).to eq(custom_logger)
    end
  end

  describe '#send_welcome_email' do
    it 'logs welcome email details' do
      expect(logger).to receive(:info).with("📧 MOCK EMAIL SENT")
      expect(logger).to receive(:info).with("  To: #{email}")
      expect(logger).to receive(:info).with("  Subject: Welcome to our platform!")
      expect(logger).to receive(:info).with("  User ID: #{user_id}")
      expect(logger).to receive(:info).with("  Content: Welcome! Thank you for joining our platform.")

      service.send_welcome_email(email: email, user_id: user_id)
    end

    it 'simulates processing time' do
      expect(service).to receive(:sleep).with(0.1)

      service.send_welcome_email(email: email, user_id: user_id)
    end

    it 'returns success result with correct structure' do
      result = service.send_welcome_email(email: email, user_id: user_id)

      expect(result).to be_a(Hash)
      expect(result[:success]).to be true
      expect(result[:message]).to eq("Mock welcome email sent to #{email}")
      expect(result[:email_id]).to be_a(String)
      expect(result[:email_id].length).to eq(36) # UUID length
    end

    it 'generates unique email IDs for each call' do
      result1 = service.send_welcome_email(email: email, user_id: user_id)
      result2 = service.send_welcome_email(email: email, user_id: user_id)

      expect(result1[:email_id]).not_to eq(result2[:email_id])
    end

    it 'includes email address in the success message' do
      result = service.send_welcome_email(email: email, user_id: user_id)

      expect(result[:message]).to include(email)
    end

    context 'with different email addresses' do
      let(:emails) { [ 'user@example.com', 'admin@test.org', 'customer@business.net' ] }

      it 'logs the correct email address for each call' do
        emails.each do |test_email|
          expect(logger).to receive(:info).with("  To: #{test_email}")

          service.send_welcome_email(email: test_email, user_id: user_id)
        end
      end
    end

    context 'with different user IDs' do
      let(:user_ids) { [ SecureRandom.uuid, SecureRandom.uuid, SecureRandom.uuid ] }

      it 'logs the correct user ID for each call' do
        user_ids.each do |test_user_id|
          expect(logger).to receive(:info).with("  User ID: #{test_user_id}")

          service.send_welcome_email(email: email, user_id: test_user_id)
        end
      end
    end
  end

  describe '#send_notification_email' do
    let(:subject) { 'Important Notification' }
    let(:content) { 'This is a test notification with some content.' }

    it 'logs notification email details' do
      expect(logger).to receive(:info).with("📧 MOCK NOTIFICATION EMAIL SENT")
      expect(logger).to receive(:info).with("  To: #{email}")
      expect(logger).to receive(:info).with("  Subject: #{subject}")
      expect(logger).to receive(:info).with("  Content: #{content}")

      service.send_notification_email(email: email, subject: subject, content: content)
    end

    it 'simulates processing time' do
      expect(service).to receive(:sleep).with(0.1)

      service.send_notification_email(email: email, subject: subject, content: content)
    end

    it 'returns success result with correct structure' do
      result = service.send_notification_email(email: email, subject: subject, content: content)

      expect(result).to be_a(Hash)
      expect(result[:success]).to be true
      expect(result[:message]).to eq("Mock notification email sent to #{email}")
      expect(result[:email_id]).to be_a(String)
      expect(result[:email_id].length).to eq(36) # UUID length
    end

    it 'generates unique email IDs for each call' do
      result1 = service.send_notification_email(email: email, subject: subject, content: content)
      result2 = service.send_notification_email(email: email, subject: subject, content: content)

      expect(result1[:email_id]).not_to eq(result2[:email_id])
    end

    it 'includes email address in the success message' do
      result = service.send_notification_email(email: email, subject: subject, content: content)

      expect(result[:message]).to include(email)
    end

    context 'with long content' do
      let(:long_content) { 'A' * 150 } # 150 characters

      it 'truncates content in logs to 101 characters with ellipsis' do
        expected_content = "#{'A' * 101}..."
        expect(logger).to receive(:info).with("  Content: #{expected_content}")

        service.send_notification_email(email: email, subject: subject, content: long_content)
      end
    end

    context 'with content exactly 101 characters' do
      let(:exact_content) { 'B' * 101 }

      it 'logs full content without ellipsis' do
        expect(logger).to receive(:info).with("  Content: #{exact_content}")

        service.send_notification_email(email: email, subject: subject, content: exact_content)
      end
    end

    context 'with content less than 100 characters' do
      let(:short_content) { 'Short message' }

      it 'logs full content without truncation' do
        expect(logger).to receive(:info).with("  Content: #{short_content}")

        service.send_notification_email(email: email, subject: subject, content: short_content)
      end
    end

    context 'with empty content' do
      let(:empty_content) { '' }

      it 'logs empty content' do
        expect(logger).to receive(:info).with("  Content: ")

        service.send_notification_email(email: email, subject: subject, content: empty_content)
      end
    end

    context 'with different subjects' do
      let(:subjects) { [ 'Urgent Alert', 'Weekly Newsletter', 'Account Update' ] }

      it 'logs the correct subject for each call' do
        subjects.each do |test_subject|
          expect(logger).to receive(:info).with("  Subject: #{test_subject}")

          service.send_notification_email(email: email, subject: test_subject, content: content)
        end
      end
    end
  end

  describe 'consistent behavior across methods' do
    it 'both methods return the same result structure' do
      welcome_result = service.send_welcome_email(email: email, user_id: user_id)
      notification_result = service.send_notification_email(
        email: email,
        subject: 'Test',
        content: 'Test content'
      )

      expect(welcome_result.keys).to eq(notification_result.keys)
      expect(welcome_result[:success]).to eq(notification_result[:success])
      expect(welcome_result[:email_id]).to be_a(String)
      expect(notification_result[:email_id]).to be_a(String)
    end

    it 'both methods simulate the same processing time' do
      expect(service).to receive(:sleep).with(0.1).twice

      service.send_welcome_email(email: email, user_id: user_id)
      service.send_notification_email(email: email, subject: 'Test', content: 'Test')
    end

    it 'both methods always return success: true' do
      welcome_result = service.send_welcome_email(email: email, user_id: user_id)
      notification_result = service.send_notification_email(
        email: email,
        subject: 'Test',
        content: 'Test'
      )

      expect(welcome_result[:success]).to be true
      expect(notification_result[:success]).to be true
    end
  end

  describe 'logging behavior' do
    it 'logs emoji indicators for easy identification' do
      expect(logger).to receive(:info).with("📧 MOCK EMAIL SENT")
      expect(logger).to receive(:info).with("📧 MOCK NOTIFICATION EMAIL SENT")

      service.send_welcome_email(email: email, user_id: user_id)
      service.send_notification_email(email: email, subject: 'Test', content: 'Test')
    end

    it 'uses consistent indentation for log details' do
      expect(logger).to receive(:info).with(/^  To: /)
      expect(logger).to receive(:info).with(/^  Subject: /)
      expect(logger).to receive(:info).with(/^  User ID: /)
      expect(logger).to receive(:info).with(/^  Content: /)

      service.send_welcome_email(email: email, user_id: user_id)
    end
  end

  describe 'parameter validation' do
    it 'handles named parameters correctly for welcome email' do
      expect {
        service.send_welcome_email(email: email, user_id: user_id)
      }.not_to raise_error
    end

    it 'handles named parameters correctly for notification email' do
      expect {
        service.send_notification_email(email: email, subject: 'Test', content: 'Test')
      }.not_to raise_error
    end

    # These tests ensure the service follows the same parameter patterns as the rest of the codebase
    it 'requires named parameters for welcome email' do
      expect {
        service.send_welcome_email(email, user_id)
      }.to raise_error(ArgumentError)
    end

    it 'requires named parameters for notification email' do
      expect {
        service.send_notification_email(email, 'Subject', 'Content')
      }.to raise_error(ArgumentError)
    end
  end
end
