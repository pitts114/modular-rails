# frozen_string_literal: true

# Public API for the Users engine
# This class provides a clean interface for other engines to interact with user functionality
class UsersApi
  def initialize(user_creation_service: UserCreationService.new, user_model: User, user_authentication_service: UserAuthenticationService.new, user_profile_service: UserProfileService.new, user_profile_update_service: UserProfileUpdateService.new)
    @user_creation_service = user_creation_service
    @user_model = user_model
    @user_authentication_service = user_authentication_service
    @user_profile_service = user_profile_service
    @user_profile_update_service = user_profile_update_service
  end

  # Creates a new user with signup information
  # @param username [String] the username for the new user
  # @param password [String] the password for the new user
  # @param email [String] the email address for the new user
  # @param phone_number [String, nil] optional phone number for the new user
  # @return [Hash] result with success status, user object, and any errors
  def create_user(username:, password:, email:, phone_number: nil)
    user, errors = @user_creation_service.call(username: username, password: password, email: email, phone_number: phone_number)

    if user
      { success: true, user: user, errors: [] }
    else
      { success: false, user: user, errors: errors }
    end
  rescue StandardError => e
    handle_standard_error(e, user: nil)
  end

  # Finds a user by username
  # @param username [String] the username to search for
  # @return [Hash] result with success status, user object, and any errors
  def find_user_by_username(username:)
    user = @user_model.find_by(username: username)

    if user
      { success: true, user: user, errors: [] }
    else
      { success: false, user: nil, errors: [ 'User not found' ] }
    end
  rescue StandardError => e
    handle_standard_error(e, user: nil)
  end

  # Authenticates a user with username and password
  # @param username [String] the username
  # @param password [String] the password
  # @return [Hash] result with success status, user object, and any errors
  def authenticate_user(username:, password:)
    user = @user_authentication_service.call(username: username, password: password)

    if user
      { success: true, user: user }
    else
      { success: false, errors: [ 'Invalid username or password' ] }
    end
  rescue StandardError => e
    handle_standard_error(e)
  end

  # Gets user profile information including signup details
  # @param user_id [String] the user ID
  # @return [Hash] result with success status, profile data, and any errors
  def get_user_profile(user_id:)
    profile_data = @user_profile_service.call(user_id: user_id)

    if profile_data
      { success: true, profile: profile_data, errors: [] }
    else
      { success: false, profile: nil, errors: [ 'User not found' ] }
    end
  rescue StandardError => e
    handle_standard_error(e, profile: nil)
  end

  # Updates user profile information
  # @param user_id [String] the user ID
  # @param email [String, nil] new email address
  # @param phone_number [String, nil] new phone number
  # @return [Hash] result with success status, user object, and any errors
  def update_user_profile(user_id:, email: nil, phone_number: nil)
    user, errors = @user_profile_update_service.call(user_id: user_id, email: email, phone_number: phone_number)

    if user && errors.empty?
      { success: true, user: user, errors: [] }
    else
      { success: false, user: nil, errors: errors }
    end
  rescue StandardError => e
    handle_standard_error(e, user: nil)
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
