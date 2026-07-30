# FinAI - GitHub Copilot Instructions

## Project Overview

FinAI is an AI-powered Personal Financial Management mobile application.

The system consists of:

- Flutter Mobile Application
- Spring Boot Backend
- FastAPI AI Service
- MySQL Database

Generate production-quality code only.

---

# General Rules

- Follow Clean Architecture.
- Follow SOLID principles.
- Follow DRY and KISS principles.
- Keep code readable and maintainable.
- Use meaningful names.
- Keep files small and focused.
- Do not generate unnecessary code.
- Do not generate placeholder methods unless requested.
- Prefer composition over inheritance.

---

# Flutter Architecture

Always follow Feature-First Clean Architecture.

Folder structure:

lib/
├── app/
├── core/
├── features/
├── shared/
└── main.dart

Each feature should contain:

- data/
- domain/
- presentation/

Do not move files outside this structure.

---

# State Management

Use Riverpod.

Prefer:

- Provider
- StateNotifierProvider
- AsyncNotifier

Avoid Provider package.

Avoid setState unless explicitly requested.

---

# Routing

Use GoRouter.

- Keep routes inside app/router.
- Use named routes.
- Avoid Navigator.push unless required.

---

# UI Guidelines

Use Material 3.

Always:

- Responsive layouts
- Reusable widgets
- const constructors
- Proper widget separation

Never:

- Hardcode colors
- Hardcode text styles

Use AppTheme.

---

# Theme

All colors must come from AppTheme.

Do not place colors inside widgets.

Use Theme.of(context).

---

# Networking

Use Dio.

Create reusable API services.

Never call APIs directly from UI.

---

# Local Storage

Use:

- Flutter Secure Storage
- Shared Preferences

Never store sensitive information in Shared Preferences.

---

# Error Handling

Always:

- Handle exceptions
- Return meaningful errors
- Avoid empty catch blocks

---

# Code Style

Follow Dart lints.

Use:

- final whenever possible
- const constructors
- Small functions
- Single Responsibility Principle

Avoid:

- Long methods
- Duplicate code

---

# Naming Conventions

Classes:
PascalCase

Variables:
camelCase

Files:
snake_case

Constants:
lowerCamelCase unless static const.

---

# Comments

Write comments only when they improve understanding.

Do not comment obvious code.

---

# Performance

Prefer:

- const widgets
- Lazy loading
- Efficient rebuilds

Avoid unnecessary widget rebuilding.

---

# Backend Integration

Flutter communicates only with Spring Boot REST APIs.

Do not directly communicate with FastAPI.

Architecture:

Flutter
↓

Spring Boot
↓

FastAPI (AI)

---

# AI Integration

AI features include:

- Financial Prediction
- Expense Forecast
- AI Recommendation

AI logic belongs only in FastAPI.

Never generate ML code inside Flutter.

---

# Authentication

Use JWT authentication.

Never store passwords.

Use secure token storage.

---

# Git Rules

Generate code suitable for Git Flow.

Never rename project folders.

Never change project architecture.

---

# Testing

Generate testable code.

Prefer dependency injection.

Avoid tightly coupled classes.

---

# Important

Always generate production-ready code.

Do not generate deprecated Flutter APIs.

Do not introduce new architecture patterns.

Maintain consistency across the entire project.