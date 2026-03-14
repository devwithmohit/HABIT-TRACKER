System Architecture: Habit Tracker (Offline-First)

Architecture Pattern
Clean Architecture (Uncle Bob) adapted for Flutter
┌─────────────────────────────────────────┐
│ Presentation Layer │
│ (UI + State Management - Riverpod) │
└─────────────────┬───────────────────────┘
│
┌─────────────────▼───────────────────────┐
│ Application Layer │
│ (Use Cases / Business Logic) │
└─────────────────┬───────────────────────┘
│
┌─────────────────▼───────────────────────┐
│ Domain Layer │
│ (Entities + Repository Interfaces) │
└─────────────────┬───────────────────────┘
│
┌─────────────────▼───────────────────────┐
│ Data / Infrastructure Layer │
│ (Hive, Notifications, Ads, IAP) │
└─────────────────────────────────────────┘

Module Breakdown
Module 1: Domain Layer (Core Business Logic)
Location: lib/domain/
Responsibilities:

Define pure Dart entities (no Flutter dependencies)
Repository interfaces (contracts)
Business rules

Files:
domain/
├── entities/
│ ├── habit.dart # Habit model
│ ├── habit_log.dart # Daily completion record
│ └── user_settings.dart # App settings
├── repositories/
│ ├── habit_repository.dart # Interface
│ └── settings_repository.dart # Interface
└── value_objects/
└── streak.dart # Streak calculation logic
Key Entity: Habit
dartclass Habit {
final String id;
final String name;
final String icon;
final String color;
final List<int> activeDays; // [1,2,3,4,5] = Mon-Fri
final DateTime createdAt;
final bool isArchived;
}
Key Entity: HabitLog
dartclass HabitLog {
final String habitId;
final DateTime date;
final bool isCompleted;
final DateTime? completedAt;
}

```

---

### **Module 2: Data Layer** (Persistence + External Services)
**Location:** `lib/data/`

**Responsibilities:**
- Implement repository interfaces
- Hive adapters + type registration
- Local database operations
- No business logic here

**Files:**
```

data/
├── models/
│ ├── habit_model.dart # Hive TypeAdapter
│ └── habit_log_model.dart # Hive TypeAdapter
├── repositories/
│ ├── habit_repository_impl.dart
│ └── settings_repository_impl.dart
├── datasources/
│ ├── local/
│ │ └── hive_database.dart # Box initialization
│ └── remote/
│ └── (future: sync adapter if needed)
└── mappers/
└── habit_mapper.dart # Model ↔ Entity conversion

```

**Hive Boxes:**
- `habits` → List<Habit>
- `habit_logs` → Map<String, List<HabitLog>> (habitId → logs)
- `settings` → UserSettings

---

### **Module 3: Application Layer** (Use Cases)
**Location:** `lib/application/`

**Responsibilities:**
- Orchestrate business logic
- One use case = one user action
- Call repositories, compute streaks, handle errors

**Files:**
```

application/
├── usecases/
│ ├── habits/
│ │ ├── create_habit.dart
│ │ ├── update_habit.dart
│ │ ├── delete_habit.dart
│ │ ├── get_all_habits.dart
│ │ └── reorder_habits.dart
│ ├── logs/
│ │ ├── mark_habit_complete.dart
│ │ ├── unmark_habit_complete.dart
│ │ └── get_habit_logs.dart
│ └── analytics/
│ ├── calculate_streak.dart
│ ├── get_weekly_summary.dart
│ └── check_habit_due_today.dart
└── dto/
└── habit_with_streak.dart # Data Transfer Object
Example Use Case:
dartclass MarkHabitComplete {
final HabitRepository \_repo;

Future<Result<Streak>> call(String habitId, DateTime date) async {
// 1. Validate date
// 2. Create HabitLog
// 3. Save to repo
// 4. Recalculate streak
// 5. Return updated streak
}
}

```

---

### **Module 4: Presentation Layer** (UI + State)
**Location:** `lib/presentation/`

**Responsibilities:**
- Flutter widgets
- Riverpod providers (state management)
- Handle user input
- Display data from use cases

**Files:**
```

presentation/
├── providers/
│ ├── habits_provider.dart # StateNotifierProvider
│ ├── habit_logs_provider.dart
│ └── settings_provider.dart
├── screens/
│ ├── home/
│ │ ├── home_screen.dart
│ │ └── widgets/
│ │ ├── habit_tile.dart
│ │ └── streak_badge.dart
│ ├── add_habit/
│ │ └── add_habit_screen.dart
│ ├── calendar/
│ │ └── calendar_screen.dart
│ └── settings/
│ └── settings_screen.dart
├── theme/
│ ├── app_theme.dart
│ └── app_colors.dart
└── utils/
└── date_formatter.dart
State Management Pattern:
dart// Provider
final habitsProvider = StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
return HabitsNotifier(ref.read(habitRepositoryProvider));
});

// Notifier
class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
final HabitRepository \_repo;

Future<void> loadHabits() async {
state = const AsyncValue.loading();
state = await AsyncValue.guard(() => \_repo.getAllHabits());
}
}

```

---

### **Module 5: Core / Shared** (Infrastructure)
**Location:** `lib/core/`

**Responsibilities:**
- Dependency injection
- Error handling
- Constants
- Notifications setup
- Ads + IAP wrappers

**Files:**
```

core/
├── di/
│ └── injection.dart # Riverpod providers setup
├── error/
│ ├── failures.dart # Sealed class for errors
│ └── exceptions.dart
├── notifications/
│ └── notification_service.dart # flutter_local_notifications wrapper
├── monetization/
│ ├── ad_service.dart # AdMob wrapper
│ └── purchase_service.dart # IAP wrapper
└── constants/
├── app_constants.dart
└── storage_keys.dart

```

---

## **Data Flow Example: Mark Habit Complete**
```

1. User taps habit tile
   ↓
2. [UI] HabitTile → calls provider method
   ↓
3. [Provider] HabitsNotifier.markComplete(habitId)
   ↓
4. [Use Case] MarkHabitComplete.call(habitId, today)
   ↓
5. [Repository] HabitRepositoryImpl.saveLog(log)
   ↓
6. [Data] HiveDatabase.saveToBox('habit_logs', log)
   ↓
7. [Use Case] CalculateStreak.call(habitId)
   ↓
8. [Provider] Updates state → UI rebuilds

```

---

## **Folder Structure (Full)**
```

lib/
├── main.dart
├── core/
│ ├── di/
│ ├── error/
│ ├── notifications/
│ ├── monetization/
│ └── constants/
├── domain/
│ ├── entities/
│ ├── repositories/
│ └── value_objects/
├── data/
│ ├── models/
│ ├── repositories/
│ ├── datasources/
│ └── mappers/
├── application/
│ ├── usecases/
│ └── dto/
└── presentation/
├── providers/
├── screens/
├── theme/
└── utils/

Key Design Decisions
DecisionReasonClean ArchitectureTestable, maintainable, scalableOffline-firstNo backend = faster, cheaperHive over SQLiteSimpler, no migrations, encryptedRiverpod over BlocLess boilerplate, better DXUse Cases patternSingle responsibility, easy testingRepository patternSwap Hive for cloud later (if needed)

What's Missing (Intentionally)
❌ Authentication (offline-first = local only)
❌ Backend sync (future Module 6 if needed)
❌ Complex analytics (keep it minimal)
❌ Social features (bloat)
