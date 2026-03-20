# Architecture

## Overview
Y0 To-Do App is a Flutter application built with Riverpod, Hive, and a layered architecture. The UI focuses on productivity workflows (search, filters, smart suggestions, and voice input) while the data layer encapsulates local persistence, notification scheduling, and AI-driven analysis.

## Layers
- **UI (screens/widgets)**: Flutter widgets and screens for tasks, filters, search, and settings.
- **State (providers)**: Riverpod providers orchestrate state, pagination, and AI/voice services.
- **Domain (models)**: Task, filters, categories, settings, and analysis models.
- **Data (repositories/services)**: Hive persistence, notification service, AI/NLP parsing, speech services.

## Dependency Flow
```
UI (screens/widgets)
   ↓
Providers (Riverpod)
   ↓
Repositories + Services
   ↓
Hive / Device APIs
```

## Key Modules
- `lib/screens/`: Home, add/edit task, statistics, settings.
- `lib/widgets/`: Reusable UI pieces (filters, search, error handling, voice input).
- `lib/providers/`: Task, search, AI/voice, settings, pagination state.
- `lib/repositories/`: TaskRepository (CRUD + validation).
- `lib/services/`: AIService, SpeechService, NotificationService, HapticService.
- `lib/models/`: Task, TaskCategory, TaskFilter, SearchHistory, AppSettings.

## Runtime Flow (Example: Add Task)
1. UI triggers add action.
2. TasksNotifier validates and sends task to `TaskRepository`.
3. Repository writes to Hive.
4. TasksNotifier refreshes list and schedules notifications if enabled.

## Error Handling
- `ErrorHandler` captures Flutter and platform errors.
- ErrorBoundary surfaces UI-friendly fallback views for widget errors.

## Accessibility
- `AccessibilityHelper` provides semantic labels for tasks, filters, and buttons.
- UI widgets wrap actionable controls with Semantics and tooltips.
