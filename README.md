# Habit Tracker - Clean Architecture Flutter App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)

**Fast. Clean. Zero friction habit tracker.**

_A production-ready habit tracking app built with Flutter and Clean Architecture_

[Features](#features) | [Architecture](#architecture) | [Getting Started](#getting-started)

</div>

---

## About

**Habit Tracker** is a modern, feature-complete mobile and web application designed to help users build and maintain healthy habits. Built with **Clean Architecture** principles, the app is fully offline-first with no backend dependency.

### Key Highlights

- **Production-Ready**: Stable, fully functional
- **Clean Architecture**: Domain / Data / Application / Presentation layers
- **Cross-Platform**: Runs on Android, iOS, and Web
- **Offline-First**: Local-first architecture with Hive
- **Material Design 3**: Modern UI with Light, Dark, and AMOLED themes
- **Smart Reminders**: Daily notifications with timezone support
- **Monetization**: AdMob integration and premium via In-App Purchase
- **Type-Safe**: Sealed `Result<T>` pattern for error handling

---

## Features

### Core Features

| Feature              | Description                                                                   |
| -------------------- | ----------------------------------------------------------------------------- |
| **Habit Management** | Create, edit, delete, and archive habits with emoji icons and color coding    |
| **Daily Tracking**   | Tap to mark habits complete, with date-based toggle support                   |
| **Streaks**          | Current streak, longest streak, streak-at-risk detection                      |
| **Calendar View**    | Last 90 days view with color-coded completion heatmap and chain visualization |
| **Statistics**       | Weekly bar chart, 30-day per-habit performance, best/worst day                |
| **Notifications**    | Daily reminders at custom times, with skip-weekends support                   |
| **Themes**           | Light, Dark, AMOLED Dark, and System automatic themes                         |
| **Drag Reorder**     | Reorder habits with drag-and-drop (order persists across restarts)            |
| **Archive**          | Swipe-to-archive and long-press context menu                                  |
| **Data Export**      | CSV and text report export (premium)                                          |
| **Onboarding**       | First-launch walkthrough with notification permission and sample habit        |
| **Offline-First**    | Works completely offline with Hive local storage                              |

### Monetization

| Feature               | Description                                                    |
| --------------------- | -------------------------------------------------------------- |
| **Premium Unlock**    | In-app purchase for unlimited habits (store-localized pricing) |
| **Restore Purchases** | Recover previous purchases on reinstall                        |
| **Banner Ads**        | AdMob integration for free tier (hidden for premium users)     |
| **Free Tier**         | 10 habits limit                                                |
| **Premium Tier**      | 100 habits + ad-free + data export                             |

### Settings

| Feature                   | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| **Theme Picker**          | Light / Dark / AMOLED / System                       |
| **Notification Controls** | Enable/disable, custom time, skip weekends           |
| **Language**              | en, hi, es, fr, de, ja (locale wired to MaterialApp) |
| **Reset to Defaults**     | Restore all settings to factory defaults             |
| **Clear All Data**        | Wipe habits and logs                                 |
| **Privacy & Terms**       | Links via url_launcher                               |

---

## Architecture

This project follows **Clean Architecture** with 4 layers:

```
lib/
├── domain/              # Business logic & entities
│   ├── entities/        # Habit, HabitLog, UserSettings
│   ├── repositories/    # Repository interfaces
│   └── value_objects/   # Streak
│
├── data/                # Data layer implementation
│   ├── models/          # Hive models with TypeAdapters
│   ├── repositories/    # Repository implementations
│   ├── datasources/     # HiveDatabase
│   └── mappers/         # Entity <-> Model mappers
│
├── application/         # Use cases & DTOs
│   ├── usecases/        # 11 use cases (CRUD + analytics)
│   └── dto/             # Result<T>, HabitWithStreak
│
├── presentation/        # UI layer
│   ├── providers/       # Riverpod StateNotifiers
│   ├── screens/         # 6 screens (Home, AddHabit, Calendar, Statistics, Settings, Onboarding)
│   ├── theme/           # AppTheme, AppColors
│   └── utils/           # DateFormatter
│
└── core/                # Shared infrastructure
    ├── di/              # Riverpod provider definitions
    ├── error/           # Exception hierarchy
    ├── constants/       # AppConstants
    ├── notifications/   # NotificationService
    ├── monetization/    # AdService, PurchaseService
    └── services/        # ExportService
```

### Design Patterns

- **Clean Architecture**: Domain <- Data <- Application <- Presentation
- **Repository Pattern**: Abstract data sources behind interfaces
- **Use Case Pattern**: One class = one user action
- **Result Pattern**: `sealed class Result<T>` (Success / Failure)
- **Provider Pattern**: Riverpod for dependency injection and state
- **Mapper Pattern**: Separate domain entities from data models

---

## Getting Started

### Prerequisites

- Flutter SDK: `>=3.3.0 <4.0.0`
- Dart SDK: `>=3.0.0`
- Android Studio / Xcode (for mobile development)

### Installation

```bash
# Clone the repository
git clone https://github.com/devwithmohit/habit-tracker-clean-arch.git
cd habit-tracker-clean-arch

# Install dependencies
flutter pub get

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

#### AdMob Setup (Optional)

Update `lib/core/constants/app_constants.dart` with your AdMob IDs:

```dart
static const String adMobBannerIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String adMobBannerIdIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

#### In-App Purchase Setup (Optional)

Update `lib/core/constants/app_constants.dart`:

```dart
static const String premiumProductId = 'your_premium_product_id';
```

---

## Dependencies

### Core

- `flutter_riverpod` - State management
- `hive` / `hive_flutter` - Local database
- `flutter_localizations` - Locale support

### Features

- `flutter_local_notifications` - Push notifications
- `timezone` - Timezone support
- `google_mobile_ads` - AdMob integration
- `in_app_purchase` - IAP integration

### Utilities

- `intl` - Internationalization
- `uuid` - UUID generation
- `url_launcher` - External links
- `path_provider` - File system paths

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## Contact

**Developer**: Mohit

- GitHub: [@devwithmohit](https://github.com/devwithmohit)

---

<div align="center">

**Built with Flutter**

[Report Bug](https://github.com/devwithmohit/habit-tracker-clean-arch/issues) | [Request Feature](https://github.com/devwithmohit/habit-tracker-clean-arch/issues)

</div>
