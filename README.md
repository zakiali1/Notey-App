# Notey App

Notey App is a Flutter-based personal productivity app for managing tasks, organizing priorities, and tracking progress over time. The project focuses on a clean, modern mobile-first experience with local persistence, smart task filtering, and lightweight analytics.

## Why this app?

This project was designed to keep task management simple and fast:

- Capture tasks with titles, notes, categories, and due dates
- Sort by urgency with low, medium, and high priorities
- Filter by status, category, and priority to focus on what matters
- Use a lightweight analytics dashboard to review completion trends
- Keep everything saved locally without needing a backend

## Features

- Task creation, editing, completion toggling, and deletion
- Category tracking for personal, work, shopping, health, education, and other items
- Priority levels to highlight urgent work
- Search and filtering tools for large task lists
- Due-date awareness for overdue items and better time planning
- Local data storage using `shared_preferences`
- Light and dark mode support
- Analytics view with summary cards and charts
- Cross-platform Flutter app support for Android, iOS, macOS, web, and Windows

## Screens

The app is organized around a simple dashboard flow:

- Home screen with bottom navigation
- Tasks screen for viewing and managing the active list
- Add task screen for creating new items
- Analytics screen for completion and distribution insights
- Profile screen for personal app details and preferences

## Project structure

```text
lib/
├── main.dart
├── models/
│   └── task.dart
├── services/
│   └── task_service.dart
├── screens/
│   ├── add_task_screen.dart
│   ├── analytics_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   └── tasks_screen.dart
├── utils/
│   └── theme_provider.dart
└── widgets/
    ├── ask_card.dart
    └── task_card.dart
```

## Tech stack

- Flutter
- Dart
- Material 3 design
- `shared_preferences` for local storage
- `fl_chart` for visual analytics
- `google_fonts` for typography

## Prerequisites

Before running the application, make sure you have the following installed:

- Flutter SDK
- A supported IDE such as VS Code or Android Studio
- An emulator or physical device for testing

## Getting started

1. Clone the repository:

```bash
git clone https://github.com/zakiali1/Notey-App.git
cd Notey-App
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

You can also target a specific platform, for example:

```bash
flutter run -d chrome
flutter run -d android
```

## Development notes

- Tasks are persisted locally using `SharedPreferences`, so no backend or database setup is required.
- The analytics layer computes totals, completion rate, overdue items, and category/priority breakdowns.
- Theme preferences are also stored locally so the app can remember the user's selected mode.

## Future improvements

Some useful enhancements for future iterations include:

- Drag-and-drop task ordering
- Reminders and notifications
- Searchable tags or labels
- Export/import data
- Multi-user sync or cloud backup

## License

This project is currently distributed without a formal license file.
