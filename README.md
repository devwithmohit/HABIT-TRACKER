# 🎯 Habit Tracker - Clean Architecture Flutter App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)

**Fast. Clean. Zero friction habit tracker.**

_A production-ready habit tracking app built with Flutter and Clean Architecture_

[Features](#-features) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---

## 📖 About

**Habit Tracker** is a modern, feature-complete mobile and web application designed to help users build and maintain healthy habits. Built with **Clean Architecture** principles, the app is scalable, maintainable, and follows industry best practices.

### 🎯 Key Highlights

- ✅ **Production-Ready**: Fully tested and stable
- 🏗️ **Clean Architecture**: Modular, testable, and maintainable
- 📱 **Cross-Platform**: Runs on Android, iOS, and Web
- 💾 **Offline-First**: Local-first architecture with Hive
- 🎨 **Material Design 3**: Modern UI with dark mode support
- 🔔 **Smart Reminders**: Daily notifications with timezone support
- 💰 **Monetization**: AdMob integration and premium features via IAP
- 🔒 **Type-Safe**: Sealed classes and Result pattern for error handling

---

## ✨ Features

### Core Features

| Feature                 | Description                                                     | Status      |
| ----------------------- | --------------------------------------------------------------- | ----------- |
| 🎯 **Habit Management** | Create, edit, delete, and archive habits                        | ✅ Complete |
| ✓ **Daily Tracking**    | Mark habits as complete with date-based tracking                | ✅ Complete |
| 📊 **Statistics**       | Current streak, best streak, completion rate, total completions | ✅ Complete |
| 🔔 **Notifications**    | Daily reminders at custom times with timezone support           | ✅ Complete |
| 🌙 **Dark Mode**        | Automatic theme switching based on system preferences           | ✅ Complete |
| 🔍 **Search & Filter**  | Search by name, filter by category, sort by multiple criteria   | ✅ Complete |
| 📁 **Categories**       | Organize habits into 8 predefined categories                    | ✅ Complete |
| 🎨 **Color Themes**     | Choose from 12 vibrant color options                            | ✅ Complete |
| 📥 **Archive**          | Archive completed habits without losing data                    | ✅ Complete |
| 💾 **Offline-First**    | Works completely offline with Hive local storage                | ✅ Complete |

### Monetization Features

| Feature                  | Description                          | Status      |
| ------------------------ | ------------------------------------ | ----------- |
| 💰 **Premium Unlock**    | In-app purchase for unlimited habits | ✅ Complete |
| 📱 **Banner Ads**        | AdMob integration for free tier      | ✅ Complete |
| 🔓 **Free Tier**         | 10 habits limit for free users       | ✅ Complete |
| ⭐ **Premium Tier**      | 100 habits + ad-free experience      | ✅ Complete |
| 🔄 **Restore Purchases** | Cross-device purchase restoration    | ✅ Complete |

### Categories

- 🏃 Health & Fitness
- 📚 Learning & Education
- 💼 Work & Productivity
- 🧘 Mindfulness & Meditation
- 💰 Finance & Saving
- 🎨 Hobbies & Creativity
- 👥 Social & Relationships
- 🏠 Home & Lifestyle

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a clear separation of concerns:

```
lib/
├── domain/              # Business logic & entities
│   ├── entities/        # Core domain models
│   ├── repositories/    # Repository interfaces
│   └── value_objects/   # Value objects (Category, Color, etc.)
│
├── data/                # Data layer implementation
│   ├── models/          # Hive models with TypeAdapters
│   ├── repositories/    # Repository implementations
│   ├── datasources/     # Local data sources
│   └── mappers/         # Data ↔ Domain mappers
│
├── application/         # Application business logic
│   ├── usecases/        # 11 use cases (CRUD + business logic)
│   └── dto/             # Result pattern for error handling
│
├── presentation/        # UI layer
│   ├── providers/       # Riverpod state management
│   ├── screens/         # 6 main screens
│   ├── widgets/         # Reusable UI components
│   ├── theme/           # Material 3 theming
│   └── utils/           # UI utilities
│
└── core/                # Shared infrastructure
    ├── di/              # Dependency injection (Riverpod)
    ├── error/           # Error handling (Failures & Exceptions)
    ├── constants/       # App-wide constants
    ├── notifications/   # Notification service
    └── monetization/    # Ad & IAP services
```

### Design Patterns

- **Clean Architecture**: Domain ← Data ← Application ← Presentation
- **Repository Pattern**: Abstract data sources
- **Use Case Pattern**: Single responsibility business logic
- **Result Pattern**: Type-safe error handling
- **Provider Pattern**: Riverpod for state management
- **Mapper Pattern**: Separate domain and data models
- **Service Pattern**: Platform services (notifications, ads, IAP)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `>=3.3.0 <4.0.0`
- Dart SDK: `>=3.0.0`
- Android Studio / Xcode (for mobile development)
- Physical device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/devwithmohit/habit-tracker-clean-arch.git
cd habit-tracker-clean-arch

# Install dependencies
flutter pub get

# Generate code (Hive TypeAdapters, Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

### Configuration

#### 1. AdMob Setup (Optional)

Update `lib/core/constants/app_constants.dart` with your AdMob IDs:

```dart
static const String androidBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String iosBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

#### 2. In-App Purchase Setup (Optional)

Update `lib/core/constants/app_constants.dart` with your product IDs:

```dart
static const String premiumProductId = 'your_premium_product_id';
```

#### 3. Firebase Setup (Optional)

1. Add `google-services.json` to `android/app/`
2. Add `GoogleService-Info.plist` to `ios/Runner/`

---

## 📱 Screens

1. **Home Screen**: Display all habits with search/filter
2. **Habit Form Screen**: Create/edit habits
3. **Habit Detail Screen**: View statistics and manage completions
4. **Statistics Screen**: Global stats across all habits
5. **Archive Screen**: View archived habits
6. **Settings Screen**: Notifications, premium unlock, theme settings

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/domain/entities/habit_test.dart
```

---

## 📦 Dependencies

### Core

- `flutter_riverpod` (^2.5.1) - State management
- `hive` (^2.2.3) - Local database
- `hive_flutter` (^1.1.0) - Hive Flutter integration

### Features

- `flutter_local_notifications` (^17.2.3) - Push notifications
- `timezone` (^0.9.4) - Timezone support
- `google_mobile_ads` (^5.2.0) - AdMob integration
- `in_app_purchase` (^3.2.0) - IAP integration

### Analytics (Optional)

- `firebase_core` (^3.6.0)
- `firebase_analytics` (^11.3.3)
- `firebase_crashlytics` (^4.1.3)

### Utilities

- `intl` (^0.19.0) - Internationalization
- `uuid` (^4.5.1) - UUID generation

### Dev Dependencies

- `build_runner` (^2.4.8) - Code generation
- `riverpod_generator` (^2.4.0) - Riverpod code gen
- `hive_generator` (^2.0.1) - Hive TypeAdapter gen
- `flutter_lints` (^4.0.0) - Linting

---

## 🗺️ Roadmap

### Upcoming Features

- [ ] Data export/import (JSON, CSV)
- [ ] Cloud sync with Firebase
- [ ] Social sharing of achievements
- [ ] Custom habit templates
- [ ] Habit streaks leaderboard
- [ ] Widget support (Android/iOS)
- [ ] Multi-language support
- [ ] Advanced analytics & insights
- [ ] Habit dependencies & chains
- [ ] Custom reminder sounds

### Planned Improvements

- [ ] Performance optimizations
- [ ] Enhanced accessibility
- [ ] Expanded test coverage
- [ ] CI/CD pipeline setup
- [ ] Documentation improvements

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Standards

- Follow Clean Architecture principles
- Write unit tests for new features
- Use `flutter analyze` before committing
- Follow Dart style guide
- Document public APIs

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Riverpod](https://riverpod.dev/) - State management
- [Hive](https://docs.hivedb.dev/) - Fast local database
- [Material Design 3](https://m3.material.io/) - Design system

---

## 📧 Contact

**Developer**: Mohit

- GitHub: [@devwithmohit](https://github.com/devwithmohit)
- Repository: [habit-tracker-clean-arch](https://github.com/devwithmohit/habit-tracker-clean-arch)

---

## ⭐ Show Your Support

If you find this project helpful, please consider giving it a ⭐ star on GitHub!

---

<div align="center">

**Built with ❤️ using Flutter**

[Report Bug](https://github.com/devwithmohit/habit-tracker-clean-arch/issues) • [Request Feature](https://github.com/devwithmohit/habit-tracker-clean-arch/issues)

</div>
