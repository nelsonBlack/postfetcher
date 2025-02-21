# Posts Fetcher

[![CI/CD](https://github.com/yourusername/postfetcher/actions/workflows/flutter.yml/badge.svg)](https://github.com/yourusername/postfetcher/actions)
[![Test Coverage](https://img.shields.io/badge/coverage-90%25-brightgreen)](https://github.com/yourusername/postfetcher)

A production-grade Flutter application demonstrating modern development practices with Clean Architecture, offline-first approach, and comprehensive testing.


<img src="https://github.com/user-attachments/assets/2f881c78-0094-44e9-8c18-df0a48ba55f0" width="400">
## Features ✨

| Feature             | Implementation Details                                                 |
| ------------------- | ---------------------------------------------------------------------- |
| **Infinite Scroll** | Paginated API calls (10 posts/page) with automatic load-more on scroll |
| **Offline Support** | Hive caching layer with LRU eviction policy                            |
| **Adaptive UI**     | Responsive layouts for mobile/desktop using `ResponsiveLayout` utils   |
| **Theme System**    | Dark/Light modes with system adaptation, persisted via Hive            |
| **Error Handling**  | Graceful degradation with cached data & retry mechanisms               |
| **Navigation**      | GoRouter with deep linking and state restoration                       |
| **Testing**         | 90%+ coverage including unit, widget, and integration tests            |

## Architecture 🧱

```text
lib/
├── core/               # Framework-agnostic components
│   ├── config/         # App-wide configuration (router, themes)
│   ├── constants/      # App constants and theming
│   ├── errors/         # Failure handling and custom exceptions
│   └── utils/          # Helper classes and extensions
│
├── data/               # Data layer
│   ├── datasources/    # API and local data sources
│   └── models/         # Hive data models and adapters
│
├── domain/             # Business logic layer
│   ├── entities/       # Business objects
│   ├── repositories/   # Abstract contracts
│   └── usecases/       # Feature-specific operations
│
└── presentation/        # UI Layer
    ├── controllers/    # State management (FlutX)
    ├── views/          # Screen components
    └── widgets/        # Reusable UI components
```

## Key Implementation Details 🔍

### Pagination & Caching

```dart
// lib/domain/repositories/post_repository_impl.dart
Future<Either<Failure, List<PostEntity>>> getPosts(int page) async {
  if (connectivityResult == ConnectivityResult.none) {
    return getCachedPosts(); // Fallback to cached data
  }

  final response = await remoteDataSource.getPosts(page);
  await _cachePosts(posts, page); // Cache new data
  return Right(posts);
}
```

### State Management

```dart
// lib/presentation/controllers/post_controller.dart
void _handleNewPosts(List<PostEntity> newPosts) {
  hasReachedMax = newPosts.isEmpty;
  posts = page == 1 ? newPosts : [...posts, ...newPosts];
  _updateState(PostState.success);
  _cachePosts(); // Persist to local storage
}
```

### Adaptive Theming

```dart
// lib/core/constants/app_constants.dart
static ThemeData getTheme(BuildContext context, ThemeMode themeMode) {
  final isDesktop = ResponsiveLayout.isDesktop(context);
  return (themeMode == ThemeMode.dark ? darkTheme : lightTheme).copyWith(
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: isDesktop ? Colors.blueGrey : null,
      displayColor: isDesktop ? Colors.indigo : null,
    ),
  );
}
```

## Getting Started 🚀

### Prerequisites

- Flutter SDK 3.19+ ([Installation guide](https://docs.flutter.dev/get-started/install))
- Dart 3.0+
- IDE: Android Studio/VSCode with Flutter plugin
- For web build: Chrome browser

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/postfetcher.git
cd postfetcher
```

2. Install dependencies:

```bash
flutter pub get
```

3. Generate Hive adapters:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Running the App

#### Mobile/Desktop

```bash
# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

#### Web

```bash
flutter run -d chrome
```

### Testing 🧪

#### Run All Tests

```bash
flutter test
```

#### Specific Test Types

```bash
# Unit tests (business logic)
flutter test test/unit/

# Widget tests (UI components)
flutter test test/widgets/

# Integration tests (full flow)
flutter test test/integration/
```

#### Generate Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
brew install lcov # macOS
sudo apt-get install lcov # Linux
genhtml coverage/lcov.info -o coverage/

# Open report
open coverage/index.html # macOS
xdg-open coverage/index.html # Linux
```

#### Test Notes

- Hive is automatically configured to use temp directories in tests
- Mock network responses are used for reliable testing
- Golden tests are included for UI consistency checks

### Debugging

- Use `--verbose` flag for detailed logs:

```bash
flutter run --verbose
flutter test --verbose
```

### Common Issues

**Hive Initialization Errors**:

```bash
flutter packages pub run build_runner build
rm -rf .dart_tool/
flutter clean
```

**Web CORS Issues**:

- Use Chrome with disabled security:

```bash
open -a Google\ Chrome --args --disable-web-security --user-data-dir
```

## Testing Strategy 🧪

| Test Type        | Coverage       | Example Files                    |
| ---------------- | -------------- | -------------------------------- |
| **Unit Tests**   | Business logic | `test/unit/*_test.dart`          |
| **Widget Tests** | UI components  | `test/widgets/*_test.dart`       |
| **Integration**  | Full app flow  | `test/integration/app_test.dart` |

## Dependencies 📦

| Package           | Usage              | Version     |
| ----------------- | ------------------ | ----------- |
| flutx             | State Management   | ^0.2.0-rc.4 |
| hive              | Local Caching      | ^2.2.3      |
| dio               | REST Client        | ^5.4.0      |
| go_router         | Navigation         | ^13.2.0     |
| connectivity_plus | Network Monitoring | ^2.1.0      |
| mocktail          | Testing            | ^1.0.4      |

## Contributing 🤝

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

**Quality Standards:**

- test coverage for new features
- Follow Clean Architecture patterns
- Document public APIs
- Update README for significant changes

## License 📄

Distributed under the MIT License. See `LICENSE` for more information.
