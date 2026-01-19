# frozen_string_literal: true

class UserProfileUpdateService
  def initialize(user_signup_info_model: UserSignupInfo, logger: Rails.logger)
    @user_signup_info_model = user_signup_info_model
    @logger = logger
  end

  # Updates a user's profile information
  # @param user_id [String] the user ID
  # @param email [String, nil] new email address
  # @param phone_number [String, nil] new phone number
  # @return [Array] tuple of [user, errors] where errors are user-friendly validation messages
  def call(user_id:, email: nil, phone_number: nil)
    signup_info = find_signup_info(user_id: user_id)
    return [ nil, [ "User not found" ] ] unless signup_info

    update_attributes = build_update_attributes(email: email, phone_number: phone_number)

    if update_attributes.empty?
      return [ signup_info.user, [] ]
    end

    if signup_info.update(update_attributes)
      @logger.info "Profile updated for user: #{user_id}"
      [ signup_info.user, [] ]
    else
      [ nil, signup_info.errors.full_messages ]
    end
  end

  private

  def find_signup_info(user_id:)
    @user_signup_info_model.find_by(user_id: user_id)
  end

  def build_update_attributes(email:, phone_number:)
    attributes = {}
    attributes[:email] = email if email.present?
    attributes[:phone_number] = phone_number unless phone_number.nil?
    attributes
  end
end
