class UserContactPreferenceCreationService
  def initialize(
    user_contact_preference_model: UserContactPreference,
    email_service: MockEmailService.new,
    users_api: UsersApi.new,
    logger: Rails.logger
  )
    @user_contact_preference_model = user_contact_preference_model
    @email_service = email_service
    @users_api = users_api
    @logger = logger
  end

  # Creates a new contact preference with default notification settings
  # @param user_id [String] the user ID
  # @return [Array] tuple of [contact_preference, errors] where errors are validation messages
  def call(user_id:)
    contact_preference = create_contact_preference(user_id: user_id)

    if contact_preference.persisted?
      send_welcome_email(user_id: user_id)
      [ contact_preference, [] ]
    else
      [ nil, contact_preference.errors.full_messages ]
    end
  end

  private

  def create_contact_preference(user_id:)
    @user_contact_preference_model.new(
      user_id: user_id
    ).tap(&:save)
  end

  def send_welcome_email(user_id:)
    # Fetch user email from Users engine
    result = @users_api.get_user_profile(user_id: user_id)

    if result[:success]
      email = result[:profile].email
      @email_service.send_welcome_email(email: email, user_id: user_id)
      @logger.info "Welcome email sent to #{email} for user #{user_id}"
    else
      @logger.error "Failed to fetch user profile for welcome email: #{result[:errors].join(', ')}"
    end
  rescue => e
    @logger.error "Failed to send welcome email: #{e.message}"
  end
end
