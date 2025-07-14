class MockEmailService
  def initialize(logger: Rails.logger)
    @logger = logger
  end

  def send_welcome_email(email:, user_id:)
    @logger.info "📧 MOCK EMAIL SENT"
    @logger.info "  To: #{email}"
    @logger.info "  Subject: Welcome to our platform!"
    @logger.info "  User ID: #{user_id}"
    @logger.info "  Content: Welcome! Thank you for joining our platform."

    # Simulate processing time
    sleep(0.1)

    {
      success: true,
      message: "Mock welcome email sent to #{email}",
      email_id: SecureRandom.uuid
    }
  end

  def send_notification_email(email:, subject:, content:)
    @logger.info "📧 MOCK NOTIFICATION EMAIL SENT"
    @logger.info "  To: #{email}"
    @logger.info "  Subject: #{subject}"
    @logger.info "  Content: #{content[0..100]}#{'...' if content.length > 101}"

    sleep(0.1)

    {
      success: true,
      message: "Mock notification email sent to #{email}",
      email_id: SecureRandom.uuid
    }
  end
end
