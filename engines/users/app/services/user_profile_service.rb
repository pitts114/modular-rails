# frozen_string_literal: true

# Service for handling user profile retrieval
class UserProfileService
  def initialize(user_model: User)
    @user_model = user_model
  end

  # Gets user profile information including signup details
  # @param user_id [String] the user ID
  # @return [Hash] user profile data or nil if user not found
  def call(user_id:)
    user = @user_model.find_by(id: user_id)
    return nil unless user

    {
      username: user.username,
      email: user.email,
      phone_number: user.phone_number,
      created_at: user.created_at
    }
  end
end
