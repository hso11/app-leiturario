# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Lint/analyze
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Code generation (DI + models)
dart run build_runner build

# Watch mode for code generation
dart run build_runner watch

# Build
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web
flutter build windows   # Windows
```

> After adding/modifying `@injectable` classes, always run `dart run build_runner build` to regenerate `lib/injection.config.dart`.

## Architecture

Clean Architecture with BLoC state management:

```
lib/
├── main.dart                      # Entry: initializes GetIt DI, launches app
├── injection.dart / .config.dart  # GetIt + Injectable DI (auto-generated)
├── core/                          # Constants (colors, strings), error types, base UseCase
├── data/
│   ├── auth/                      # GoogleAuthService, MicrosoftAuthService
│   ├── datasources/local/         # SQLite via sqflite (BookLocalDatasource, NoteLocalDatasource)
│   ├── datasources/remote/        # GoogleDriveStorage, OneDriveStorage, SyncService
│   ├── models/                    # DTOs with JSON/SQLite serialization (BookModel, NoteModel)
│   └── repositories/              # Implementations of domain interfaces
├── domain/
│   ├── entities/                  # Book, Note (pure Dart, no framework deps)
│   ├── repositories/              # Abstract interfaces
│   └── usecases/book/ & note/     # One class per use case, each calls a single repository method
└── presentation/
    ├── app.dart                   # Root widget: MaterialApp.router + MultiBlocProvider
    ├── blocs/auth/                # AuthBloc – login/logout, triggers sync on login
    ├── blocs/book/                # BookBloc – full CRUD
    ├── blocs/note/                # NoteBloc – note CRUD
    ├── blocs/sync/                # SyncCubit – manual push/pull
    ├── pages/                     # home, auth, book_detail, notes_feed
    └── router/app_router.dart     # GoRouter routes
```

**Data flow:** Page → BLoC/Cubit → UseCase → Repository interface → DataSource (SQLite or HTTP)

## Key Conventions

- **Dependency Injection**: All services/repos/blocs use `@injectable` / `@lazySingleton`. Register new classes with these annotations and regenerate.
- **State Management**: BLoC for complex flows (book CRUD, auth), Cubit for simpler state (sync). Events/states use `Equatable`.
- **Repository Pattern**: Domain layer only touches abstract interfaces; data layer implements them.
- **Local DB**: SQLite (`booktracker.db`). Schema defined in `lib/data/datasources/local/database_helper.dart`. Books and Notes tables; notes have a foreign key to books with `ON DELETE CASCADE`.
- **Cloud Sync**: Full DB exported as JSON to Google Drive / OneDrive. `SyncService` orchestrates push (upload) and pull (download + merge).
- **UI Strings**: All user-facing strings in `lib/core/constants/app_strings.dart` (Portuguese).
- **Colors**: Defined in `lib/core/constants/app_colors.dart` (blue primary, purple secondary).
