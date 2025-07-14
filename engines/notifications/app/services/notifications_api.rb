class NotificationsApi
  def initialize(
    user_contact_preference_model: UserContactPreference,
    user_contact_preference_creation_service: UserContactPreferenceCreationService.new,
    user_contact_preference_update_service: UserContactPreferenceUpdateService.new,
    logger: Rails.logger
  )
    @user_contact_preference_model = user_contact_preference_model
    @user_contact_preference_creation_service = user_contact_preference_creation_service
    @user_contact_preference_update_service = user_contact_preference_update_service
    @logger = logger
  end

  # Creates a new contact preference
  # @param user_id [String] the user ID
  # @param email [String] the email address
  # @param phone_number [String, nil] optional phone number
  # @return [Hash] result with success status, contact preference, and any errors
  def create_contact_preference(user_id:, email:, phone_number: nil)
    contact_preference, errors = @user_contact_preference_creation_service.call(
      user_id: user_id,
      email: email,
      phone_number: phone_number
    )

    if contact_preference
      { success: true, contact_preference: contact_preference, errors: [] }
    else
      { success: false, contact_preference: nil, errors: errors }
    end
  rescue StandardError => e
    handle_standard_error(e, contact_preference: nil)
  end

  # Gets a contact preference by user ID
  # @param user_id [String] the user ID
  # @return [Hash] result with success status, contact preference, and any errors
  def get_contact_preference(user_id:)
    contact_preference = @user_contact_preference_model.find_by(user_id: user_id)

    if contact_preference
      { success: true, contact_preference: contact_preference, errors: [] }
    else
      { success: false, contact_preference: nil, errors: [ "Contact preference not found for user #{user_id}" ] }
    end
  rescue StandardError => e
    handle_standard_error(e, contact_preference: nil)
  end

  # Updates a contact preference
  # @param user_id [String] the user ID
  # @param email [String, nil] new email address
  # @param phone_number [String, nil] new phone number
  # @param email_notifications_enabled [Boolean, nil] email notification preference
  # @param phone_notifications_enabled [Boolean, nil] phone notification preference
  # @return [Hash] result with success status, contact preference, and any errors
  def update_contact_preference(user_id:, email: nil, phone_number: nil, email_notifications_enabled: nil, phone_notifications_enabled: nil)
    contact_preference, errors = @user_contact_preference_update_service.call(
      user_id: user_id,
      email: email,
      phone_number: phone_number,
      email_notifications_enabled: email_notifications_enabled,
      phone_notifications_enabled: phone_notifications_enabled
    )

    if contact_preference
      { success: true, contact_preference: contact_preference, errors: [] }
    else
      { success: false, contact_preference: nil, errors: errors }
    end
  rescue StandardError => e
    handle_standard_error(e, contact_preference: nil)
  end

  private

  # Handles StandardError exceptions consistently across all API methods
  # @param error [StandardError] the exception that occurred
  # @param additional_keys [Hash] additional keys to include in the error response
  # @return [Hash] standardized error response
  def handle_standard_error(error, **additional_keys)
    base_response = { success: false, errors: [ "An unexpected error occurred: #{error.message}" ] }
    base_response.merge(additional_keys)
  end
end
