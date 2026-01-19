# frozen_string_literal: true

# Service for handling user profile retrieval
class UserProfileService
  def initialize(user_signup_info_model: UserSignupInfo)
    @user_signup_info_model = user_signup_info_model
  end

  # Gets user profile information including signup details
  # @param user_id [String] the user ID
  # @return [OpenStruct] user profile data or nil if user not found
  def call(user_id:)
    signup_info = @user_signup_info_model.includes(:user).find_by(user_id: user_id)
    return nil unless signup_info

    OpenStruct.new(
      username: signup_info.user&.username,
      email: signup_info.email,
      phone_number: signup_info.phone_number,
      created_at: signup_info.user&.created_at
    )
  end
end
