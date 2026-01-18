class UserCreatedEventSubscriber
  def initialize(notifications_api: NotificationsApi.new, logger: Rails.logger)
    @notifications_api = notifications_api
    @logger = logger
  end

  def call(event)
    payload = event.payload

    @logger.info "UserCreatedEventSubscriber: Processing user created event for user #{payload[:user_id]}"

    result = @notifications_api.create_contact_preference(
      user_id: payload[:user_id]
    )

    if result[:success]
      @logger.info "UserCreatedEventSubscriber: Successfully created contact preferences for user #{payload[:user_id]}"
    else
      @logger.error "UserCreatedEventSubscriber: Failed to create contact preferences for user #{payload[:user_id]}: #{result[:errors]}"
    end
  rescue => e
    @logger.error "UserCreatedEventSubscriber: Error processing user created event: #{e.message}"
    @logger.error e.backtrace.join("\n")
  end
end
