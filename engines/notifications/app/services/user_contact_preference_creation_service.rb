class UserContactPreferenceCreationService
  def initialize(
    user_contact_preference_model: UserContactPreference,
    email_service: MockEmailService.new,
    logger: Rails.logger
  )
    @user_contact_preference_model = user_contact_preference_model
    @email_service = email_service
    @logger = logger
  end

  # Creates a new contact preference with email welcome notification
  # @param user_id [String] the user ID
  # @param email [String] the email address
  # @param phone_number [String, nil] optional phone number
  # @return [Array] tuple of [contact_preference, errors] where errors are validation messages
  def call(user_id:, email:, phone_number: nil)
    contact_preference = create_contact_preference(
      user_id: user_id,
      email: email,
      phone_number: phone_number
    )

    if contact_preference.persisted?
      send_welcome_email(email: email, user_id: user_id)
      [ contact_preference, [] ]
    else
      [ nil, contact_preference.errors.full_messages ]
    end
  end

  private

  def create_contact_preference(user_id:, email:, phone_number:)
    @user_contact_preference_model.new(
      user_id: user_id,
      email: email,
      phone_number: phone_number
    ).tap(&:save)
  end

  def send_welcome_email(email:, user_id:)
    @email_service.send_welcome_email(email: email, user_id: user_id)
    @logger.info "Welcome email sent to #{email} for user #{user_id}"
  rescue => e
    @logger.error "Failed to send welcome email to #{email}: #{e.message}"
  end
end
