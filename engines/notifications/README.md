# Notifications Engine

The **Notifications Engine** handles user communication preferences, email services, and event-driven reactions to user activities across the application.

## 🎯 Purpose

This engine manages all notification-related functionality:
- User contact preferences (email/phone settings)
- Email delivery services (with development-friendly mocking)
- Event subscription and handling for user lifecycle events
- Automatic setup of user communication preferences

## 📁 Key Components

### Models
- **[`UserContactPreference`](app/models/user_contact_preference.rb)** - User notification preferences and contact information

### Services
- **[`NotificationsApi`](app/services/notifications_api.rb)** - Public API for notification operations
- **[`MockEmailService`](app/services/mock_email_service.rb)** - Development email service with detailed logging
- **[`UserCreatedEventSubscriber`](app/services/user_created_event_subscriber.rb)** - Handles user creation events

### Configuration
- **[Event Subscriptions](config/initializers/event_subscriptions.rb)** - Configures Rails event listeners

## 🔗 Dependencies

- **Core Engine** - Inherits from `ApplicationRecord` and other base classes
- **No direct engine dependencies** - Communicates via events only

## 📡 Events Consumed

- `users.user_created` - Automatically creates contact preferences and sends welcome email when users sign up

## 🔌 Public API

```ruby
# Create contact preferences
result = NotificationsApi.new.create_contact_preference(
  user_id: user.id,
  email: 'john@example.com',
  phone_number: '+1234567890',
  email_enabled: true,
  phone_enabled: false
)
# => { success: true, contact_preference: <UserContactPreference>, errors: [] }

# Send welcome email
MockEmailService.new.send_welcome_email(
  email: 'john@example.com',
  username: 'john'
)
```

## 🏗️ Architecture Role

The Notifications engine operates independently, reacting to events from other engines:

```
┌─────────────────────────────────────────┐
│          Users Engine                   │ ──emits──▶ users.user_created
└─────────────────────────────────────────┘
                    │
                    ▼
         ActiveSupport::Notifications
                    │
                    ▼
┌─────────────────────────────────────────┐
│      Notifications Engine               │
│                                         │
│  UserCreatedEventSubscriber ────────▶   │
│  • Creates contact preferences          │
│  • Sends welcome emails                 │
└─────────────────────────────────────────┘
                    ▲
                    │
┌─────────────────────────────────────────┐
│              UI Engine                  │ ──calls──▶ NotificationsApi
│    (Contact Preference Management)      │
└─────────────────────────────────────────┘
```

## 📧 Email Development

In development, the `MockEmailService` logs all email activity instead of sending real emails:
- Check `log/development.log` for email delivery confirmations
- All email content and metadata is logged for debugging
- No external email service configuration required

## 📋 Development Notes

- Event subscribers are automatically registered via initializers
- Follow dependency injection patterns for all services
- Use structured logging for email operations
- Keep email templates simple and focused
- Test both event handling and direct API calls
