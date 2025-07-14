# Users Engine

The **Users Engine** handles all user-related domain logic, including user management, authentication, and user data operations.

## 🎯 Purpose

This engine encapsulates the user domain, providing:
- User account creation and management
- Password-based authentication using `has_secure_password`
- User signup information handling (email, phone)
- Clean APIs for user operations
- Event emission for cross-cutting concerns

## 📁 Key Components

### Models
- **[`User`](app/models/user.rb)** - Core user model with authentication
- **[`UserSignupInfo`](app/models/user_signup_info.rb)** - Extended user profile information

### Services
- **[`UsersApi`](app/services/users_api.rb)** - Public API for user operations
- **[`UserCreationService`](app/services/user_creation_service.rb)** - Handles user creation workflow with event emission

## 🔗 Dependencies

- **Core Engine** - Inherits from `ApplicationRecord` and other base classes
- **No other engines** - This engine is self-contained for user domain logic

## 📡 Events Emitted

- `users.user_created` - Fired when a new user is successfully created, includes user data for other engines to react to

## 🔌 Public API

```ruby
# Create a new user
result = UsersApi.new.create_user(
  username: 'john',
  password: 'secret',
  email: 'john@example.com',
  phone_number: '+1234567890'
)
# => { success: true, user: <User>, errors: [] }
```

## 🏗️ Architecture Role

The Users engine provides domain logic that the UI engine consumes and emits events that the Notifications engine responds to:

```
┌─────────────────────────────────────────┐
│              UI Engine                  │ ──calls──▶ UsersApi
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│          Users Engine                   │ ──emits──▶ users.user_created
│         (Domain Logic)                  │
└─────────────────────────────────────────┘
                    │                              │
                    ▼                              ▼
┌─────────────────────────────────────────┐    ┌─────────────────────┐
│           Core Engine                   │    │ Notifications Engine │
│        (Foundation Layer)               │    │   (Event Handler)    │
└─────────────────────────────────────────┘    └─────────────────────┘
```

## 📋 Development Notes

- Follow dependency injection patterns for all services
- Use named arguments for method parameters
- Return structured responses from API methods
- Emit events for actions that other engines need to know about
- Keep this engine focused on user domain logic only
