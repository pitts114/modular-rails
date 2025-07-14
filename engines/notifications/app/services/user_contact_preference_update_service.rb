class UserContactPreferenceUpdateService
  def initialize(user_contact_preference_model: UserContactPreference, logger: Rails.logger)
    @user_contact_preference_model = user_contact_preference_model
    @logger = logger
  end

  # Updates a contact preference for a user
  # @param user_id [String] the user ID
  # @param email [String, nil] new email address
  # @param phone_number [String, nil] new phone number
  # @param email_notifications_enabled [Boolean, nil] email notification preference
  # @param phone_notifications_enabled [Boolean, nil] phone notification preference
  # @return [Array] tuple of [contact_preference, errors]
  def call(user_id:, email: nil, phone_number: nil, email_notifications_enabled: nil, phone_notifications_enabled: nil)
    contact_preference = find_contact_preference(user_id: user_id)
    return [ nil, [ "Contact preference not found for user #{user_id}" ] ] unless contact_preference

    update_attributes = build_update_attributes(
      email: email,
      phone_number: phone_number,
      email_notifications_enabled: email_notifications_enabled,
      phone_notifications_enabled: phone_notifications_enabled
    )

    update_contact_preference(contact_preference: contact_preference, update_attributes: update_attributes)
  end

  private

  def find_contact_preference(user_id:)
    @user_contact_preference_model.find_by(user_id: user_id)
  end

  def build_update_attributes(email:, phone_number:, email_notifications_enabled:, phone_notifications_enabled:)
    attributes = {}

    attributes[:email] = email if email
    attributes[:phone_number] = phone_number if phone_number
    attributes[:email_notifications_enabled] = email_notifications_enabled unless email_notifications_enabled.nil?
    attributes[:phone_notifications_enabled] = phone_notifications_enabled unless phone_notifications_enabled.nil?

    attributes
  end

  def update_contact_preference(contact_preference:, update_attributes:)
    if contact_preference.update(update_attributes)
      [ contact_preference, [] ]
    else
      [ nil, contact_preference.errors.full_messages ]
    end
  end
end
