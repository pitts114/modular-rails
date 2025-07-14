# Configure event subscriptions for the notifications engine
Rails.application.config.to_prepare do
  # Subscribe to user creation events
  ActiveSupport::Notifications.subscribe('users.user_created') do |event|
    UserCreatedEventSubscriber.new.call(event)
  end

  # Future event subscriptions can be added here
  # ActiveSupport::Notifications.subscribe('users.user_updated') do |event|
  #   UserUpdatedEventSubscriber.new.call(event)
  # end

  Rails.logger.info "Notifications engine: Event subscriptions configured"
end
