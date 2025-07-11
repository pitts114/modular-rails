# GitHub Copilot Instructions

These are custom instructions for using GitHub Copilot in this repository:

## Dependency Injection
- Always prefer dependency injection over hard-coding dependencies. Pass dependencies (such as services, clients, or collaborators) into classes or methods via initializer arguments or method parameters.
- Avoid using global state or directly instantiating dependencies inside methods or classes unless absolutely necessary.

## Named Arguments
- Always use named arguments when defining or calling methods, functions, or initializers that accept multiple parameters. This improves clarity and reduces errors.

## Testing
- When writing tests, use test doubles (e.g., `double(:foo)`) to mock dependencies and collaborators.
- Prefer using RSpec's `double` for stubbing and mocking.
- Avoid using real implementations in unit tests unless integration is being explicitly tested.
- Do not typically use instance_double(Foo), use double(:foo), for example, instead.
- Always run tests using `bundle exec rspec` to ensure the correct environment and dependencies are used.

---

By following these instructions, code will be more maintainable, testable, and consistent with the project's conventions.
