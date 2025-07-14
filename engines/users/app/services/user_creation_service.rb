# frozen_string_literal: true

class UserCreationService
  def initialize(active_record_base: ActiveRecord::Base, user_model: User, user_signup_info_model: UserSignupInfo, logger: Rails.logger, notifications: ActiveSupport::Notifications)
    @active_record_base = active_record_base
    @user_model = user_model
    @user_signup_info_model = user_signup_info_model
    @logger = logger
    @notifications = notifications
  end

  # Creates a new user with signup information
  # @param username [String] the username for the new user
  # @param password [String] the password for the new user
  # @param email [String] the email address for the new user
  # @param phone_number [String, nil] optional phone number for the new user
  # @return [Array] tuple of [user, errors] where errors are user-friendly validation messages
  def call(username:, password:, email:, phone_number: nil)
    user = nil
    errors = []

    begin
      @active_record_base.transaction do
        user = create_user!(username: username, password: password)
        create_signup_info!(user: user, email: email, phone_number: phone_number)
      end

      # Emit event only after transaction has been committed successfully
      emit_user_created_event(user: user) if user
    rescue ActiveRecord::RecordInvalid => e
      errors = extract_user_friendly_errors(e.record)
      user = nil  # Transaction was rolled back, no user was persisted
    end

    [ user, errors ]
  end

  private

  def create_user!(username:, password:)
    @user_model.create!(username: username, password: password)
  end

  def create_signup_info!(user:, email:, phone_number:)
    user.create_user_signup_info!(email: email, phone_number: phone_number)
  end

  def extract_user_friendly_errors(record)
    errors = []
    errors.concat(record.errors.full_messages) if record.errors.any?

    # If the record has signup info with errors, collect those too
    if record.respond_to?(:user_signup_info) && record.user_signup_info&.errors&.any?
      errors.concat(record.user_signup_info.errors.full_messages)
    end

    errors
  end

  def emit_user_created_event(user:)
    @notifications.instrument('users.user_created', {
      user_id: user.id,
      username: user.username,
      email: user.user_signup_info&.email,
      phone_number: user.user_signup_info&.phone_number,
      created_at: user.created_at
    })

    @logger.info "UserCreated event emitted for user: #{user.id}"
  end
end
