# Core Engine

The **Core Engine** provides the foundational layer for the modular Rails application, containing base classes and shared functionality that other engines depend on.

## 🎯 Purpose

This engine serves as the foundation layer, providing:
- Base controller classes that other engines inherit from
- Shared model classes like `ApplicationRecord` and `ApplicationController`
- Common utilities and helpers used across the application
- Centralized configuration and initialization logic

## 📁 Key Components

- **[`ApplicationController`](app/controllers/application_controller.rb)** - Base controller with shared authentication and session management
- **[`ApplicationRecord`](app/models/application_record.rb)** - Base Active Record class with common model functionality

## 🔗 Dependencies

- **None** - This is the foundation engine that other engines depend on
- All other engines (`users`, `notifications`, `ui`) inherit from classes defined here

## 🏗️ Architecture Role

The Core engine sits at the bottom of the dependency hierarchy:

```
┌─────────────────────────────────────────┐
│              UI Engine                  │
│         (Presentation Layer)            │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│          Users Engine                   │
│         (Domain Logic)                  │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│           Core Engine                   │
│        (Foundation Layer)               │
└─────────────────────────────────────────┘
```

## 📋 Development Notes

- Keep this engine lightweight and focused on truly shared functionality
- Avoid adding domain-specific logic here
- Changes to this engine affect all other engines, so maintain backward compatibility
