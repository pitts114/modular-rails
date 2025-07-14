# frozen_string_literal: true

# Service for handling user authentication
class UserAuthenticationService
  def initialize(user_model: User)
    @user_model = user_model
  end

  # Authenticates a user with username and password
  # @param username [String] the username
  # @param password [String] the password
  # @return [User, nil] the authenticated user if successful, nil if authentication fails
  def call(username:, password:)
    user = @user_model.find_by(username: username)

    if user&.authenticate(password)
      user
    else
      nil
    end
  end
end
