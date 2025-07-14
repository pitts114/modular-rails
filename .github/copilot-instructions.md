# Modular Rails Development Guidelines

This file contains coding standards, architectural patterns, and best practices established for this modular Rails application. Use these guidelines to maintain consistency across the codebase.

## 🏗️ Architecture Principles

### Modular Engine Structure

- **Scalable engine architecture**: Currently includes `core`, `users`, `ui` engines with room for growth
- **Core engine**: Base functionality, shared concerns, ApplicationController - foundation for all other engines
- **Domain-specific engines**: Each engine encapsulates a specific business domain (e.g., `users`, `ui`, future: `orders`, `inventory`, `notifications`)
- **UI engines**: Handle user interface concerns, controllers, views, forms for specific domains
- **No cross-engine dependencies**: Engines communicate through clean APIs only, enabling independent development and testing
- **Growth pattern**: New engines can be added as business domains expand, following the same architectural principles

### Dependency Injection Pattern

```ruby
# ✅ GOOD: Always inject dependencies via initializer
class UsersApi
  def initialize(user_creation_service: UserCreationService.new, user_model: User)
    @user_creation_service = user_creation_service
    @user_model = user_model
  end
end

# ❌ AVOID: Hard-coding dependencies
class UsersApi
  def create_user(params)
    UserCreationService.new.call(params)  # Hard-coded dependency
  end
end
```

### Clean API Boundaries

```ruby
# ✅ GOOD: Structured return values
def create_user(username:, password:, email:, phone_number: nil)
  {
    success: true,
    user: user,
    errors: []
  }
end

# ❌ AVOID: Returning raw models or throwing exceptions across boundaries
def create_user(params)
  User.create!(params)  # Throws exception, no structured response
end
```

## 🧪 Testing Standards

### Test Organization

```
spec/
├── controllers/          # Controller unit tests
├── requests/            # Integration tests (full HTTP requests)
├── system/              # End-to-end browser tests
├── views/               # View template tests
├── services/            # Service object tests
├── models/              # Model tests
└── routing/             # Route tests
```

### Mocking Strategy

```ruby
# ✅ GOOD: Use test doubles for external dependencies
let(:users_api) { double(:users_api) }
let(:user_creation_service) { double(:user_creation_service) }

before do
  allow(UsersApi).to receive(:new).and_return(users_api)
  allow(users_api).to receive(:create_user).and_return(success_result)
end

# ❌ AVOID: instance_double - use simple double(:name) instead
let(:users_api) { instance_double(UsersApi) }  # Don't use this pattern
```

### Test Types

- **Unit tests**: Test individual methods in isolation with mocked dependencies
- **Integration tests**: Test full request/response cycles with mocked external services
- **System tests**: Test complete user flows end-to-end
- **Both mocked and real tests**: Include both for comprehensive coverage

### Form Parameter Testing

```ruby
# ✅ ALWAYS test parameter structure
it 'generates form fields with correct nested parameter names' do
  expect(rendered).to have_field('user[username]')
  expect(rendered).to have_field('user[password]')
  # Verify scope: :user creates proper nesting
end
```

## 🎨 Code Style

### Named Arguments

```ruby
# ✅ GOOD: Always use named arguments for multiple parameters
def create_user(username:, password:, email:, phone_number: nil)
  # Implementation
end

# Call with named arguments
create_user(username: 'john', password: 'secret', email: 'john@example.com')

# ❌ AVOID: Positional arguments for multiple parameters
def create_user(username, password, email, phone_number = nil)
  # Hard to understand at call site
end
```

### Service Objects

```ruby
# ✅ GOOD: Service object pattern that returns tuples
class UserCreationService
  def initialize(active_record_base: ActiveRecord::Base, user_model: User, ...)
    @active_record_base = active_record_base
    @user_model = user_model
  end

  def call(username:, password:, email:, phone_number: nil)
    @active_record_base.transaction do
      user = create_user(username: username, password: password)
      create_signup_info(user: user, email: email, phone_number: phone_number) if user.persisted?

      if user.persisted? && user.user_signup_info&.persisted?
        emit_user_created_event(user: user)
        [user, []]  # Success: object with empty errors
      else
        errors = collect_errors(user: user)
        [nil, errors]  # Failure: nil object with errors
      end
    end
  end

  private

  # ✅ GOOD: Pass arguments to private methods instead of using instance variables
  def create_user(username:, password:)
    @user_model.new(username: username, password: password).tap(&:save)
  end

  def create_signup_info(user:, email:, phone_number:)
    user.build_user_signup_info(email: email, phone_number: phone_number).tap(&:save)
  end

  def collect_errors(user:)
    # Private method receives explicit arguments
  end

  def emit_user_created_event(user:)
    # Private method receives explicit arguments
  end
end
```

### API Layer Pattern

```ruby
# ✅ GOOD: API classes are responsible only for calling services and building result hashes
class NotificationsApi
  def initialize(
    user_contact_preference_creation_service: UserContactPreferenceCreationService.new,
    user_contact_preference_update_service: UserContactPreferenceUpdateService.new,
    logger: Rails.logger
  )
    @user_contact_preference_creation_service = user_contact_preference_creation_service
    @user_contact_preference_update_service = user_contact_preference_update_service
    @logger = logger
  end

  def create_contact_preference(user_id:, email:, phone_number: nil)
    contact_preference, errors = @user_contact_preference_creation_service.call(
      user_id: user_id,
      email: email,
      phone_number: phone_number
    )

    if contact_preference
      { success: true, contact_preference: contact_preference, errors: [] }
    else
      { success: false, contact_preference: nil, errors: errors }
    end
  rescue StandardError => e
    handle_standard_error(e, contact_preference: nil)
  end

  private

  def handle_standard_error(error, **additional_keys)
    base_response = { success: false, errors: ["An unexpected error occurred: #{error.message}"] }
    base_response.merge(additional_keys)
  end
end

# ❌ AVOID: API methods doing business logic, model interactions, or complex validations
class NotificationsApi
  def create_contact_preference(user_id:, email:, phone_number: nil)
    # Don't do this - no direct model interactions in API
    contact_preference = UserContactPreference.new(user_id: user_id, email: email)

    # Don't do this - no complex business logic in API
    if contact_preference.save
      EmailService.send_welcome_email(email: email, user_id: user_id)
      # Complex response building...
    end
  end
end
```

**API Layer Responsibilities:**

- **Service Orchestration**: Call appropriate services with parameters
- **Response Formatting**: Build consistent `{success:, object:, errors:}` response hashes
- **Error Handling**: Catch and handle `StandardError` exceptions uniformly
- **Dependency Injection**: Accept services as dependencies, not create them

**Service Layer Return Pattern:**

- **Success**: `[object, []]` - object with empty errors array
- **Failure**: `[nil, errors_array]` - nil object with error messages
- **Never**: `[object, errors]` - object with errors (inconsistent pattern)

````

### Error Handling
```ruby
# ✅ GOOD: Collect and return structured errors
def collect_errors(user:)
  errors = []
  errors.concat(user.errors.full_messages) if user.errors.any?
  if user.user_signup_info&.errors&.any?
    errors.concat(user.user_signup_info.errors.full_messages)
  end
  errors
end
````

## 🌐 UI/UX Patterns

### Form Guidelines

```erb
<!-- ✅ GOOD: Always use scope for nested parameters -->
<%= form_with url: users_path, scope: :user, local: true do |form| %>
  <%= form.text_field :username, required: true, class: "form-control" %>
<% end %>

<!-- ❌ AVOID: Missing scope leads to parameter structure issues -->
<%= form_with url: users_path, local: true do |form| %>
  <%= form.text_field :username %>  <!-- Creates params[:username] not params[:user][:username] -->
<% end %>
```

### Controller Actions

```ruby
# ✅ GOOD: Controller pattern
def create
  api = UsersApi.new
  result = api.create_user(
    username: user_params[:username],
    password: user_params[:password],
    email: user_params[:email],
    phone_number: user_params[:phone_number]
  )

  if result[:success]
    redirect_to success_users_path, notice: 'Account created successfully!'
  else
    @errors = result[:errors]
    render :new, status: :unprocessable_entity
  end
end

private

def user_params
  params.require(:user).permit(:username, :password, :email, :phone_number)
end
```

### Authentication & Sessions

```ruby
# ✅ GOOD: Session-based authentication helpers
def logged_in?
  session[:user_id].present?
end

def current_user_id
  session[:user_id]
end

# Use in before_action or method guards
unless logged_in?
  redirect_to login_users_path, alert: 'Please log in to view your profile'
  return
end
```

### Logout Implementation

```erb
<!-- ✅ GOOD: Use form for DELETE requests (more reliable than link with method override) -->
<%= form_with url: logout_users_path, method: :delete, local: true,
              data: { confirm: "Are you sure you want to sign out?" } do |form| %>
  <%= form.submit "Sign Out", class: "btn btn-secondary" %>
<% end %>

<!-- ❌ AVOID: Links with method override (requires JavaScript) -->
<%= link_to "Sign Out", logout_users_path, method: :delete %>
```

## 📊 Data Modeling

### UUID Primary Keys

- All models use UUID primary keys for better scalability and security
- Configured in `config/application.rb` with `config.generators.orm :active_record, primary_key_type: :uuid`

### Model Relationships

```ruby
# ✅ GOOD: Separate concerns with related models
class User < ApplicationRecord
  has_secure_password
  has_one :user_signup_info, dependent: :destroy

  # Delegate methods for clean API
  delegate :email, :phone_number, to: :user_signup_info, allow_nil: true
end

class UserSignupInfo < ApplicationRecord
  belongs_to :user
  validates :email, presence: true, uniqueness: true
end
```

## 📁 File Organization

### No Namespacing

- **Avoid Ruby namespacing**: Use simple class names without module wrappers
- **File paths**: Direct paths without nested directories for namespaces
- **Examples**: `UsersApi` not `Users::Api`, `UserCreationService` not `Users::UserCreationService`

### Engine Structure

```
engines/
├── core/
│   ├── app/controllers/application_controller.rb
│   └── lib/core/engine.rb
├── users/
│   ├── app/
│   │   ├── models/user.rb
│   │   ├── models/user_signup_info.rb
│   │   └── services/
│   │       ├── users_api.rb
│   │       └── user_creation_service.rb
│   └── spec/
└── ui/
    ├── app/
    │   ├── controllers/users_controller.rb
    │   └── views/users/
    └── spec/
```

## 🚀 Event-Driven Architecture

### Event Emission

```ruby
# ✅ GOOD: Emit events for cross-cutting concerns
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
```

## 🔧 Development Workflow

### Testing Commands

```bash
# Run all tests
bundle exec rspec --format progress

# Run specific test types
bundle exec rspec engines/users/spec/services/ --format documentation
bundle exec rspec engines/ui/spec/system/ --format documentation

# Run with pattern matching
bundle exec rspec --pattern "spec/**/*_spec.rb,engines/**/spec/**/*_spec.rb"
```

### RSpec Configuration

```ruby
# .rspec file should be minimal and flexible
--require spec_helper
--pattern "spec/**/*_spec.rb,engines/**/spec/**/*_spec.rb"

# Avoid requiring rails_helper globally to support non-Rails libraries
```

## 🛡️ Security & Best Practices

### Parameter Filtering

```ruby
# ✅ GOOD: Strong parameters with explicit permit
def user_params
  params.require(:user).permit(:username, :password, :email, :phone_number)
end

# ✅ GOOD: Separate parameter methods for different actions
def login_params
  params.require(:user).permit(:username, :password)
end
```

### Transaction Safety

```ruby
# ✅ GOOD: Use transactions for multi-model operations
@active_record_base.transaction do
  user = create_user(username: username, password: password)
  create_signup_info(user: user, email: email, phone_number: phone_number) if user.persisted?

  if user.persisted? && user.user_signup_info&.persisted?
    emit_user_created_event(user: user)
    true
  else
    errors = collect_errors(user: user)
    raise ActiveRecord::Rollback
  end
end
```

## 📝 Documentation Standards

### Comment Style

- Use clear, descriptive comments for complex business logic
- Document public API methods with parameter types and return values
- Avoid obvious comments that restate the code

### Commit Messages

- Use conventional commit format: `feat:`, `fix:`, `refactor:`, `test:`
- Be specific about what changed and why
- Reference issues when applicable

---

## 🎯 Key Takeaways

1. **Dependency Injection Over Hard Dependencies**: Always inject collaborators
2. **Named Arguments**: Use for clarity and maintainability
3. **API Layer Separation**: APIs only call services and build response hashes
4. **Service Tuple Returns**: Services return `[object, []]` or `[nil, errors]`
5. **Structured Returns**: APIs should return consistent hash structures
6. **Test Comprehensively**: Unit, integration, and system tests
7. **Clean Boundaries**: Engines communicate only through defined APIs
8. **No Namespacing**: Keep class names simple and direct
9. **Form Scoping**: Always use `scope: :user` for proper parameter nesting
10. **Event-Driven**: Emit events for cross-cutting concerns
11. **Session Auth**: Use Rails sessions for authentication state
12. **Transaction Safety**: Wrap multi-model operations in transactions

These patterns ensure maintainable, testable, and scalable code that follows Rails conventions while maintaining clean architecture principles.
