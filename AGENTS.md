# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Eval+ is a Flutter mobile application for teacher evaluation at UTS (Unidades Tecnológicas de Santander). Students can assess teaching quality and provide academic feedback. The app supports three user roles: Student, Teacher, and Admin.

## Essential Commands

```powershell
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run a single test file
flutter test test/widget_test.dart

# Lint/analyze code
flutter analyze

# Format code
dart format .

# Build Android APK
flutter build apk --release

# Clean and rebuild
flutter clean && flutter pub get

# Generate app icons (after changing assets/icon/)
dart run flutter_launcher_icons

# Generate splash screen
dart run flutter_native_splash:create
```

## Architecture

### State Management
Uses **Provider** with `ChangeNotifier` controllers. The `UserSessionController` is provided at the app root and manages user authentication state, roles, and theme palette.

### Directory Structure
- `lib/config/` - App-wide configuration: colors (`AppColors`), themes, constants (`AppConstants`), navigation
- `lib/controllers/` - State management classes extending `ChangeNotifier`
- `lib/models/` - Data models with `fromJson`/`toJson` serialization and `copyWith` methods
- `lib/services/api/` - HTTP API clients (use `AppConstants.baseUrl`)
- `lib/services/storage/` - Local storage using `flutter_secure_storage`
- `lib/screen/` - Full-page screens; content varies by role in `screen/content/{student,teacher,admin}/`
- `lib/widgets/` - Reusable UI components organized by feature
- `lib/webviews/` - WebView implementations (Microsoft OAuth)

### Role-Based Architecture
The app dynamically adapts UI and navigation based on user role (`UserRole.student`, `UserRole.teacher`, `UserRole.admin`). Each role has:
- Its own color palette from `AppColors.getPaletteForRole()`
- Role-specific content screens in `screen/content/{role}/`
- Role-specific widgets in `widgets/{role}/`

### Authentication Flow
1. `SplashScreen` checks for stored token via `AuthStorageService`
2. Token validated with backend via `AuthApiService.validateToken()`
3. Microsoft OAuth handled via `MicrosoftAuthWebView`
4. Session state managed by `UserSessionController`

### API Pattern
All API services use static methods with the pattern:
```dart
static Future<T> methodName(String token) async {
  final response = await http.get(
    Uri.parse('${AppConstants.baseUrl}/endpoint'),
    headers: {'Authorization': 'Bearer $token'},
  ).timeout(AppConstants.apiTimeout);
  // ... handle response
}
```

## Key Files

- `lib/main.dart` - App entry point, Provider setup, routing
- `lib/config/constants.dart` - API URLs, storage keys, timeouts, dimensions
- `lib/config/app_colors.dart` - Color palettes per role
- `lib/controllers/user_session_controller.dart` - Central session/auth state
- `lib/services/storage/auth_storage_service.dart` - Token persistence

## Conventions

- Models use Spanish field names matching backend API (e.g., `nombreCompleto`, `carreras`)
- Debug logging uses emoji prefixes: ✅ success, ❌ error, 📦 data, 🔍 search, 💥 exception
- UI runs in immersive mode (system bars hidden)
- All API calls include 10-second timeout via `AppConstants.apiTimeout`
