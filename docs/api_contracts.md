# API Contracts — Habit Tracker App

> **Note:** This is a fully offline-first application with **no backend server or REST API**. All operations are local. The "API contracts" documented here are the **internal interfaces** — repository contracts, use case signatures, and service interfaces — that define how layers communicate within the app.

---

## 1. Repository Contracts (Domain Layer Interfaces)

### 1.1 HabitRepository

**Location:** `lib/domain/repositories/habit_repository.dart`

The primary contract for all habit and habit-log data operations.

#### Habit Operations

| Method            | Signature                                                          | Returns       | Description                                                 |
| ----------------- | ------------------------------------------------------------------ | ------------- | ----------------------------------------------------------- |
| `getAllHabits`    | `Future<List<Habit>> getAllHabits({bool includeArchived = false})` | `List<Habit>` | Returns all habits; excludes archived unless flag is `true` |
| `getHabitById`    | `Future<Habit?> getHabitById(String id)`                           | `Habit?`      | Returns a single habit by ID, or `null` if not found        |
| `getActiveHabits` | `Future<List<Habit>> getActiveHabits()`                            | `List<Habit>` | Returns only non-archived habits                            |
| `createHabit`     | `Future<void> createHabit(Habit habit)`                            | `void`        | Persists a new habit (keyed by `habit.id`)                  |
| `updateHabit`     | `Future<void> updateHabit(Habit habit)`                            | `void`        | Overwrites an existing habit by ID                          |
| `deleteHabit`     | `Future<void> deleteHabit(String id)`                              | `void`        | Permanently removes habit AND all its associated logs       |
| `archiveHabit`    | `Future<void> archiveHabit(String id, bool isArchived)`            | `void`        | Sets the `isArchived` flag on an existing habit             |

#### HabitLog Operations

| Method                   | Signature                                                                                                                       | Returns          | Description                                                                   |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------- |
| `getLogsForHabit`        | `Future<List<HabitLog>> getLogsForHabit(String habitId)`                                                                        | `List<HabitLog>` | All logs for a given habit                                                    |
| `getLogsForDateRange`    | `Future<List<HabitLog>> getLogsForDateRange({required String habitId, required DateTime startDate, required DateTime endDate})` | `List<HabitLog>` | Logs within a date range (inclusive, dates normalized to midnight UTC)        |
| `getLogForDate`          | `Future<HabitLog?> getLogForDate({required String habitId, required DateTime date})`                                            | `HabitLog?`      | Single log for a specific habit and date                                      |
| `saveLog`                | `Future<void> saveLog(HabitLog log)`                                                                                            | `void`           | Creates or overwrites a log (keyed by `{habitId}_{YYYY-MM-DD}`)               |
| `deleteLog`              | `Future<void> deleteLog({required String habitId, required DateTime date})`                                                     | `void`           | Removes a log entry                                                           |
| `toggleHabitCompletion`  | `Future<void> toggleHabitCompletion({required String habitId, required DateTime date})`                                         | `void`           | If no log exists: creates completed log. If log exists: toggles `isCompleted` |
| `getCompletionCount`     | `Future<int> getCompletionCount(String habitId)`                                                                                | `int`            | Total number of completed logs for a habit                                    |
| `isHabitCompletedOnDate` | `Future<bool> isHabitCompletedOnDate({required String habitId, required DateTime date})`                                        | `bool`           | Whether a specific date has a completed log                                   |
| `getTodayLogs`           | `Future<List<HabitLog>> getTodayLogs()`                                                                                         | `List<HabitLog>` | All logs for today (across all habits)                                        |
| `clearAllData`           | `Future<void> clearAllData()`                                                                                                   | `void`           | Wipes all habits, logs, and settings                                          |

---

### 1.2 SettingsRepository

**Location:** `lib/domain/repositories/settings_repository.dart`

| Method                       | Signature                                               | Returns        | Description                                                   |
| ---------------------------- | ------------------------------------------------------- | -------------- | ------------------------------------------------------------- |
| `getSettings`                | `Future<UserSettings> getSettings()`                    | `UserSettings` | Returns current settings; creates defaults if none exist      |
| `updateSettings`             | `Future<void> updateSettings(UserSettings settings)`    | `void`         | Overwrites entire settings object                             |
| `updateThemeMode`            | `Future<void> updateThemeMode(String themeMode)`        | `void`         | Updates only theme mode (`system`, `light`, `dark`, `amoled`) |
| `updateNotificationsEnabled` | `Future<void> updateNotificationsEnabled(bool enabled)` | `void`         | Toggles notifications                                         |
| `updateNotificationTime`     | `Future<void> updateNotificationTime(String time)`      | `void`         | Sets notification time (`HH:mm` format)                       |
| `updateSkipWeekends`         | `Future<void> updateSkipWeekends(bool skip)`            | `void`         | Toggles weekend notification skip                             |
| `updateLanguage`             | `Future<void> updateLanguage(String language)`          | `void`         | Sets language locale code                                     |
| `markFirstLaunchComplete`    | `Future<void> markFirstLaunchComplete()`                | `void`         | Sets `isFirstLaunch = false`                                  |
| `activatePremium`            | `Future<void> activatePremium()`                        | `void`         | Sets `isPremium = true` and timestamps `premiumPurchasedAt`   |
| `isPremiumActive`            | `Future<bool> isPremiumActive()`                        | `bool`         | Returns current premium status                                |
| `resetToDefaults`            | `Future<void> resetToDefaults()`                        | `void`         | Resets all settings to factory defaults                       |
| `isFirstLaunch`              | `Future<bool> isFirstLaunch()`                          | `bool`         | Whether this is the first app launch                          |

---

## 2. Use Case Contracts (Application Layer)

Each use case follows the pattern: **one class = one user action**, returning `Result<T>` (either `Success<T>` or `Failure<T>`).

### 2.1 Habit Use Cases

#### CreateHabit

```
call({
  required String id,
  required String name,
  required String icon,
  required String color,
  required List<int> activeDays,
}) → Future<Result<Habit>>
```

| Parameter    | Type        | Constraints                          |
| ------------ | ----------- | ------------------------------------ |
| `id`         | `String`    | Unique identifier (UUID)             |
| `name`       | `String`    | Non-empty, trimmed, max 50 chars     |
| `icon`       | `String`    | Emoji string (e.g., `🎯`)            |
| `color`      | `String`    | Hex color string (e.g., `#6C63FF`)   |
| `activeDays` | `List<int>` | Non-empty, values 1–7 (Mon=1, Sun=7) |

**Success response:** `Success(Habit)` — the created entity
**Failure responses:** `Failure("Habit name cannot be empty")`, `Failure("Please select at least one active day")`, `Failure("Invalid active days")`

---

#### UpdateHabit

```
call(Habit habit) → Future<Result<Habit>>

updateFields({
  required String habitId,
  String? name,
  String? icon,
  String? color,
  List<int>? activeDays,
  bool? isArchived,
}) → Future<Result<Habit>>
```

**Success response:** `Success(Habit)` — the updated entity
**Failure responses:** `Failure("Habit name cannot be empty")`, `Failure("Habit not found")`

---

#### DeleteHabit

```
call(String habitId) → Future<Result<void>>
archive(String habitId) → Future<Result<void>>
unarchive(String habitId) → Future<Result<void>>
```

**Success response:** `Success(null)`
**Failure response:** `Failure("Habit not found")`

---

#### GetAllHabits

```
call()          → Future<Result<List<Habit>>>     // Active only
withArchived()  → Future<Result<List<Habit>>>     // All including archived
onlyArchived()  → Future<Result<List<Habit>>>     // Archived only
activeToday()   → Future<Result<List<Habit>>>     // Active on today's weekday
byId(String id) → Future<Result<Habit>>           // Single habit
```

---

#### ReorderHabits

```
call(List<String> orderedIds)                         → Future<Result<List<Habit>>>
sortByCreationDate({bool ascending = true})           → Future<Result<List<Habit>>>
sortByName({bool ascending = true})                   → Future<Result<List<Habit>>>
```

---

### 2.2 Log Use Cases

#### MarkHabitComplete

```
call({required String habitId, DateTime? date}) → Future<Result<Streak>>
today(String habitId)                           → Future<Result<Streak>>
batchToday(List<String> habitIds)               → Future<Result<List<Streak>>>
```

| Parameter | Type        | Default                      |
| --------- | ----------- | ---------------------------- |
| `habitId` | `String`    | Required                     |
| `date`    | `DateTime?` | Defaults to `DateTime.now()` |

**Success response:** `Success(Streak)` — recalculated streak after completion
**Failure responses:** `Failure("Habit not found")`, `Failure("Habit already completed for this date")`

---

#### UnmarkHabitComplete

```
call({required String habitId, DateTime? date})     → Future<Result<Streak>>
today(String habitId)                               → Future<Result<Streak>>
toggle({required String habitId, DateTime? date})   → Future<Result<Streak>>
toggleToday(String habitId)                         → Future<Result<Streak>>
```

**Success response:** `Success(Streak)` — recalculated streak after removal
**Failure responses:** `Failure("Habit not found")`, `Failure("No log found for this date")`, `Failure("Habit is not completed for this date")`

---

#### GetHabitLogs

```
call(String habitId)                                                      → Future<Result<List<HabitLog>>>
forDateRange({required String habitId, required DateTime startDate, required DateTime endDate}) → Future<Result<List<HabitLog>>>
forCurrentMonth(String habitId)                                           → Future<Result<List<HabitLog>>>
forCurrentWeek(String habitId)                                            → Future<Result<List<HabitLog>>>
completedOnly(String habitId)                                             → Future<Result<List<HabitLog>>>
forToday(String habitId)                                                  → Future<Result<HabitLog?>>
allForToday()                                                             → Future<Result<List<HabitLog>>>
```

All list results are sorted by date descending (newest first).

---

### 2.3 Analytics Use Cases

#### CalculateStreak

```
call(String habitId)                     → Future<Result<Streak>>
forAllHabits()                           → Future<Result<List<HabitWithStreak>>>
forTodayHabits()                         → Future<Result<List<HabitWithStreak>>>
topStreaks({int limit = 5})              → Future<Result<List<HabitWithStreak>>>
atRisk()                                 → Future<Result<List<HabitWithStreak>>>
```

---

#### GetWeeklySummary

```
call()                                   → Future<Result<WeeklySummary>>
forWeek(DateTime weekStart)              → Future<Result<WeeklySummary>>
```

**WeeklySummary response structure:**

| Field                 | Type            | Description                               |
| --------------------- | --------------- | ----------------------------------------- |
| `totalHabits`         | `int`           | Number of active habits                   |
| `totalCompletions`    | `int`           | Completions this week                     |
| `possibleCompletions` | `int`           | Maximum possible completions              |
| `completionRate`      | `double`        | Percentage (0–100)                        |
| `dailyCompletions`    | `Map<int, int>` | Weekday (1–7) → completion count          |
| `bestDay`             | `int`           | Weekday with most completions             |
| `worstDay`            | `int`           | Weekday with fewest completions           |
| `perfectHabits`       | `List<String>`  | Names of habits with 100% week completion |

---

#### CheckHabitDueToday

```
call(String habitId)       → Future<Result<bool>>
allDueToday()              → Future<Result<List<HabitWithStreak>>>
incompleteDueToday()       → Future<Result<List<HabitWithStreak>>>
completedToday()           → Future<Result<List<HabitWithStreak>>>
getTodayStats()            → Future<Result<TodayStats>>
```

**TodayStats response structure:**

| Field             | Type     | Description                |
| ----------------- | -------- | -------------------------- |
| `totalDue`        | `int`    | Habits due today           |
| `completed`       | `int`    | Completed so far           |
| `remaining`       | `int`    | Still to do                |
| `completionRate`  | `double` | Percentage (0–100)         |
| `allComplete`     | `bool`   | `true` if all done and > 0 |
| `noneComplete`    | `bool`   | `true` if none done        |
| `partialComplete` | `bool`   | `true` if some done        |

---

## 3. Data Transfer Objects (DTOs)

### 3.1 Result\<T\>

Sealed type for type-safe error handling.

```
sealed class Result<T>
├── Success<T>(T data)
└── Failure<T>(String message, Exception? exception)
```

**Extension methods:** `isSuccess`, `isFailure`, `dataOrNull`, `errorOrNull`, `map()`, `onSuccess()`, `onFailure()`

### 3.2 HabitWithStreak

| Field            | Type                | Description                      |
| ---------------- | ------------------- | -------------------------------- |
| `habit`          | `Habit`             | The habit entity                 |
| `streak`         | `Streak`            | Calculated streak data           |
| `needsAttention` | `bool` (computed)   | Active today but not completed   |
| `streakProgress` | `double` (computed) | `current / longest`, clamped 0–1 |

---

## 4. Core Service Interfaces

### 4.1 NotificationService

| Method                      | Signature                                                                                                                                  | Description                        |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------- |
| `initialize`                | `Future<bool> initialize()`                                                                                                                | Initialize notification plugin     |
| `requestPermissions`        | `Future<bool> requestPermissions()`                                                                                                        | Request iOS permissions            |
| `scheduleDailyNotification` | `Future<void> scheduleDailyNotification({required int hour, required int minute, String? title, String? body, bool skipWeekends = false})` | Schedule recurring reminder        |
| `showNotification`          | `Future<void> showNotification({required String title, required String body, String? payload})`                                            | Show immediate notification        |
| `cancelAllNotifications`    | `Future<void> cancelAllNotifications()`                                                                                                    | Cancel all scheduled notifications |
| `cancelNotification`        | `Future<void> cancelNotification(int id)`                                                                                                  | Cancel specific notification       |
| `getPendingNotifications`   | `Future<List<PendingNotificationRequest>> getPendingNotifications()`                                                                       | List scheduled notifications       |

### 4.2 AdService

| Method           | Signature                          | Description                          |
| ---------------- | ---------------------------------- | ------------------------------------ |
| `initialize`     | `Future<void> initialize()`        | Initialize Mobile Ads SDK            |
| `loadBannerAd`   | `Future<BannerAd?> loadBannerAd()` | Load and return a banner ad          |
| `disposeBanner`  | `void disposeBanner()`             | Dispose current banner               |
| `dispose`        | `void dispose()`                   | Dispose all ads                      |
| `bannerAd`       | `BannerAd?` (getter)               | Current loaded banner ad (or `null`) |
| `isBannerLoaded` | `bool` (getter)                    | Whether banner is ready to display   |
| `areAdsEnabled`  | `bool` (getter)                    | Whether ads feature is active        |

### 4.3 PurchaseService

| Method             | Signature                                    | Description                          |
| ------------------ | -------------------------------------------- | ------------------------------------ |
| `initialize`       | `Future<void> initialize()`                  | Initialize IAP plugin                |
| `getProducts`      | `Future<List<ProductDetails>> getProducts()` | Query available products             |
| `purchasePremium`  | `Future<bool> purchasePremium()`             | Initiate premium purchase flow       |
| `restorePurchases` | `Future<void> restorePurchases()`            | Restore previous purchases           |
| `hasPremium`       | `Future<bool> hasPremium()`                  | Check active premium status          |
| `getPremiumPrice`  | `Future<String> getPremiumPrice()`           | Get localized price string           |
| `onPurchaseUpdate` | `Function(bool)?` (callback)                 | Callback for purchase status changes |

---

## 5. Riverpod Provider Contracts (State Management)

### 5.1 Data Layer Providers

| Provider                     | Type                           | Provides                         |
| ---------------------------- | ------------------------------ | -------------------------------- |
| `hiveDatabaseProvider`       | `Provider<HiveDatabase>`       | Singleton Hive database instance |
| `habitRepositoryProvider`    | `Provider<HabitRepository>`    | `HabitRepositoryImpl`            |
| `settingsRepositoryProvider` | `Provider<SettingsRepository>` | `SettingsRepositoryImpl`         |

### 5.2 Use Case Providers

| Provider                      | Type                            | Provides                    |
| ----------------------------- | ------------------------------- | --------------------------- |
| `createHabitProvider`         | `Provider<CreateHabit>`         | Create habit use case       |
| `updateHabitProvider`         | `Provider<UpdateHabit>`         | Update habit use case       |
| `deleteHabitProvider`         | `Provider<DeleteHabit>`         | Delete habit use case       |
| `getAllHabitsProvider`        | `Provider<GetAllHabits>`        | Get habits use case         |
| `reorderHabitsProvider`       | `Provider<ReorderHabits>`       | Reorder habits use case     |
| `markHabitCompleteProvider`   | `Provider<MarkHabitComplete>`   | Mark complete use case      |
| `unmarkHabitCompleteProvider` | `Provider<UnmarkHabitComplete>` | Unmark complete use case    |
| `getHabitLogsProvider`        | `Provider<GetHabitLogs>`        | Get logs use case           |
| `calculateStreakProvider`     | `Provider<CalculateStreak>`     | Streak calculation use case |
| `getWeeklySummaryProvider`    | `Provider<GetWeeklySummary>`    | Weekly summary use case     |
| `checkHabitDueTodayProvider`  | `Provider<CheckHabitDueToday>`  | Due-today check use case    |

### 5.3 State Providers

| Provider            | Type                                                       | State Type                                        |
| ------------------- | ---------------------------------------------------------- | ------------------------------------------------- |
| `habitsProvider`    | `StateNotifierProvider<HabitsNotifier, HabitsState>`       | List of habits with streaks, loading/error states |
| `habitLogsProvider` | `StateNotifierProvider<HabitLogsNotifier, HabitLogsState>` | Habit logs with loading/error states              |
| `settingsProvider`  | `StateNotifierProvider<SettingsNotifier, SettingsState>`   | User settings with loading/error states           |

### 5.4 Convenience Providers

| Provider                | Type                   | Description                                     |
| ----------------------- | ---------------------- | ----------------------------------------------- |
| `hasPremiumProvider`    | `FutureProvider<bool>` | Checks premium status (settings + IAP fallback) |
| `todayHabitsProvider`   | `FutureProvider<...>`  | Habits due today with streaks                   |
| `weeklySummaryProvider` | `FutureProvider<...>`  | Current week summary statistics                 |

---

## 6. Data Mappers

All mappers are static utility classes with no state.

| Mapper               | Methods                                                                                 | Description                             |
| -------------------- | --------------------------------------------------------------------------------------- | --------------------------------------- |
| `HabitMapper`        | `toModel(Habit)`, `toEntity(HabitModel)`, `toEntityList(...)`, `toModelList(...)`       | Habit entity ↔ HabitModel               |
| `HabitLogMapper`     | `toModel(HabitLog)`, `toEntity(HabitLogModel)`, `toEntityList(...)`, `toModelList(...)` | HabitLog entity ↔ HabitLogModel         |
| `UserSettingsMapper` | `toModel(UserSettings)`, `toEntity(UserSettingsModel)`                                  | UserSettings entity ↔ UserSettingsModel |

---

## 7. Error Contracts

### Failure Types (sealed class hierarchy)

| Type                  | Factory Methods                                                                        |
| --------------------- | -------------------------------------------------------------------------------------- |
| `StorageFailure`      | `unableToSave()`, `unableToLoad()`, `unableToDelete()`, `corruptedData()`              |
| `ValidationFailure`   | `emptyField(name)`, `invalidFormat(name)`, `tooShort(name, min)`, `tooLong(name, max)` |
| `NetworkFailure`      | `noConnection()`, `timeout()`, `serverError()`                                         |
| `PermissionFailure`   | `notificationsDenied()`, `storageDenied()`                                             |
| `MonetizationFailure` | `purchaseFailed()`, `purchaseCancelled()`, `productNotAvailable()`, `adLoadFailed()`   |
| `NotFoundFailure`     | `habit()`, `log()`, `settings()`                                                       |
| `UnexpectedFailure`   | `unknown(exception?)`                                                                  |

### Exception Types

| Type                    | Factory Methods                                                                                    |
| ----------------------- | -------------------------------------------------------------------------------------------------- |
| `StorageException`      | `saveError(details)`, `loadError(details)`, `deleteError(details)`, `initializationError(details)` |
| `ValidationException`   | `invalidInput(field)`, `missingRequired(field)`                                                    |
| `NetworkException`      | `connectionFailed()`, `timeout()`, `serverError(statusCode)`                                       |
| `PermissionException`   | `denied(permission)`, `permanentlyDenied(permission)`                                              |
| `MonetizationException` | `purchaseError(details)`, `adError(details)`, `notInitialized()`, `productNotAvailable()`          |
| `NotFoundException`     | `resource(name)`                                                                                   |
| `CacheException`        | `readError()`, `writeError()`, `clearError()`                                                      |
