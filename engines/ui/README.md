# UI Engine

The **UI Engine** provides the presentation layer for the modular Rails application, handling all user interface concerns including controllers, views, forms, and user interactions.

## 🎯 Purpose

This engine manages the user interface layer:
- Web controllers for handling HTTP requests
- View templates and forms for user interactions
- Session management and flash messaging
- Navigation between different application features
- Form validation and error display

## 📁 Key Components

### Controllers
- **[`UsersController`](app/controllers/users_controller.rb)** - User signup, login, logout, and profile management
- **[`ContactPreferencesController`](app/controllers/contact_preferences_controller.rb)** - Contact preference CRUD operations

### Views
- **User Management** - Signup, login, and profile views with professional styling
- **Contact Preferences** - Forms for managing notification settings
- **Shared Layouts** - Common navigation and styling across all pages

## 🔗 Dependencies

- **Core Engine** - Inherits from `ApplicationController` and shared UI components
- **Users Engine** - Calls `UsersApi` for user-related operations
- **Notifications Engine** - Calls `NotificationsApi` for contact preference management

## 🎨 Features

### Authentication & Sessions
- Session-based authentication (no external gems)
- Login/logout functionality with secure session management
- Profile pages with user information display

### Form Handling
- Professional form styling with validation feedback
- Flash message system for success/error notifications
- Proper parameter scoping for nested form data

### Navigation
- Clean, responsive navigation between features
- Success and error page flows
- Intuitive user experience patterns

## 🔌 API Integration

The UI engine consumes APIs from other engines:

```ruby
# User operations
result = UsersApi.new.create_user(params)
result = UsersApi.new.authenticate_user(params)

# Contact preference operations
result = NotificationsApi.new.create_contact_preference(params)
result = NotificationsApi.new.update_contact_preference(params)
```

## 🏗️ Architecture Role

The UI engine sits at the top of the architecture, orchestrating calls to other engines:

```
┌─────────────────────────────────────────┐
│              UI Engine                  │
│         (Presentation Layer)            │
│                                         │
│  Controllers ────calls────▶ APIs        │
│  Views ──────────────────▶ Data         │
│  Forms ──────────────────▶ Validation   │
└─────────┬───────────────────────┬───────┘
          │                       │
          ▼                       ▼
┌─────────────────────┐    ┌─────────────────────┐
│   Users Engine      │    │ Notifications Engine│
│   (Domain Logic)    │    │ (Communication)     │
│                     │    │                     │
│   UsersApi          │    │   NotificationsApi  │
└─────────────────────┘    └─────────────────────┘
          │                       │
          ▼                       ▼
┌─────────────────────────────────────────┐
│           Core Engine                   │
│        (Foundation Layer)               │
└─────────────────────────────────────────┘
```

## 📋 Development Notes

- All controllers inherit from `ApplicationController` in the Core engine
- Use strong parameters for form data validation
- Follow RESTful routing conventions
- Include comprehensive view tests for form parameter structure
- Handle both success and error cases with appropriate user feedback
- Keep controllers thin - delegate business logic to engine APIs
