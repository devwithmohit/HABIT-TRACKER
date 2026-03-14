# Database Schema — Habit Tracker App

> **Database Engine:** [Hive](https://docs.hivedb.dev/) — a lightweight, pure Dart, NoSQL key-value store.
> **Storage Format:** Binary (Hive TypeAdapters) — each model is registered with a unique `typeId`.
> **Location:** Device local storage (via `Hive.initFlutter()`); no server-side database.

---

## Overview

The app uses **three Hive boxes** (analogous to tables/collections):

| Box Name     | Key Type                 | Value Type          | Type ID | Purpose                         |
| ------------ | ------------------------ | ------------------- | ------- | ------------------------------- |
| `habits`     | `String` (habit ID)      | `HabitModel`        | `0`     | Stores all habit definitions    |
| `habit_logs` | `String` (composite key) | `HabitLogModel`     | `1`     | Stores daily completion records |
| `settings`   | `String` (fixed key)     | `UserSettingsModel` | `2`     | Stores user preferences         |

---

## Box 1: `habits`

**Box type:** `Box<HabitModel>`
**Key format:** `String` — the habit's unique ID (UUID)
**Access pattern:** Key-value lookup by habit ID; full scan for listing

### Schema: HabitModel (typeId: 0)

| Field Index     | Field Name   | Type        | Required | Default           | Description                          |
| --------------- | ------------ | ----------- | -------- | ----------------- | ------------------------------------ |
| `@HiveField(0)` | `id`         | `String`    | Yes      | —                 | Unique identifier (UUID)             |
| `@HiveField(1)` | `name`       | `String`    | Yes      | —                 | Habit display name (1–50 characters) |
| `@HiveField(2)` | `icon`       | `String`    | Yes      | `🎯`              | Emoji icon for the habit             |
| `@HiveField(3)` | `color`      | `String`    | Yes      | `#6C63FF`         | Hex color code for UI theming        |
| `@HiveField(4)` | `activeDays` | `List<int>` | Yes      | `[1,2,3,4,5,6,7]` | Days of week (1=Monday, 7=Sunday)    |
| `@HiveField(5)` | `createdAt`  | `DateTime`  | Yes      | —                 | Timestamp of creation                |
| `@HiveField(6)` | `isArchived` | `bool`      | Yes      | `false`           | Soft-delete flag                     |

### Example Entry

```
Key: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
Value: HabitModel(
  id: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  name: "Morning Exercise",
  icon: "💪",
  color: "#FF6B6B",
  activeDays: [1, 2, 3, 4, 5],   // Mon-Fri
  createdAt: 2026-01-15T08:30:00.000,
  isArchived: false,
)
```

### Serialization (JSON — for export/future sync)

```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "Morning Exercise",
  "icon": "💪",
  "color": "#FF6B6B",
  "activeDays": [1, 2, 3, 4, 5],
  "createdAt": "2026-01-15T08:30:00.000",
  "isArchived": false
}
```

---

## Box 2: `habit_logs`

**Box type:** `Box<HabitLogModel>`
**Key format:** `String` — composite key `{habitId}_{YYYY-MM-DD}`
**Access pattern:** Key-value lookup by composite key; filtered scans by `habitId` and date range

### Schema: HabitLogModel (typeId: 1)

| Field Index     | Field Name    | Type        | Required | Default | Description                                            |
| --------------- | ------------- | ----------- | -------- | ------- | ------------------------------------------------------ |
| `@HiveField(0)` | `habitId`     | `String`    | Yes      | —       | Foreign key → `habits` box                             |
| `@HiveField(1)` | `date`        | `DateTime`  | Yes      | —       | Normalized to midnight UTC (date-only)                 |
| `@HiveField(2)` | `isCompleted` | `bool`      | Yes      | —       | Whether habit was completed on this date               |
| `@HiveField(3)` | `completedAt` | `DateTime?` | No       | `null`  | Exact timestamp of completion; `null` if not completed |

### Key Generation

```
compositeKey = "{habitId}_{YYYY-MM-DD}"
```

Example: `"a1b2c3d4-e5f6-7890-abcd-ef1234567890_2026-03-10"`

### Example Entries

```
Key: "a1b2c3d4_2026-03-10"
Value: HabitLogModel(
  habitId: "a1b2c3d4",
  date: 2026-03-10T00:00:00.000Z,     // Midnight UTC
  isCompleted: true,
  completedAt: 2026-03-10T07:15:23.456,
)

Key: "a1b2c3d4_2026-03-09"
Value: HabitLogModel(
  habitId: "a1b2c3d4",
  date: 2026-03-09T00:00:00.000Z,
  isCompleted: false,
  completedAt: null,
)
```

### Serialization (JSON)

```json
{
  "habitId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "date": "2026-03-10T00:00:00.000Z",
  "isCompleted": true,
  "completedAt": "2026-03-10T07:15:23.456"
}
```

### Query Patterns

| Query                         | Method            | Implementation                                          |
| ----------------------------- | ----------------- | ------------------------------------------------------- |
| Get all logs for a habit      | Scan by `habitId` | `box.values.where((log) => log.habitId == habitId)`     |
| Get log for specific date     | Direct key lookup | `box.get("{habitId}_{YYYY-MM-DD}")`                     |
| Get logs in date range        | Filter scan       | `box.values.where(...)` with date comparisons           |
| Get today's logs (all habits) | Filter scan       | `box.values.where((log) => log.date == today)`          |
| Delete all logs for a habit   | Key prefix scan   | `box.keys.where((key) => key.startsWith("{habitId}_"))` |

---

## Box 3: `settings`

**Box type:** `Box<UserSettingsModel>`
**Key format:** `String` — fixed key `"user_settings"`
**Access pattern:** Single key-value entry; only one record exists at a time

### Schema: UserSettingsModel (typeId: 2)

| Field Index     | Field Name             | Type        | Required | Default    | Description                                   |
| --------------- | ---------------------- | ----------- | -------- | ---------- | --------------------------------------------- |
| `@HiveField(0)` | `themeMode`            | `String`    | Yes      | `"system"` | UI theme: `system`, `light`, `dark`, `amoled` |
| `@HiveField(1)` | `notificationsEnabled` | `bool`      | Yes      | `true`     | Whether daily reminders are active            |
| `@HiveField(2)` | `notificationTime`     | `String`    | Yes      | `"20:00"`  | Reminder time in `HH:mm` format               |
| `@HiveField(3)` | `skipWeekends`         | `bool`      | Yes      | `false`    | Skip notifications on Sat/Sun                 |
| `@HiveField(4)` | `isPremium`            | `bool`      | Yes      | `false`    | Premium purchase status                       |
| `@HiveField(5)` | `premiumPurchasedAt`   | `DateTime?` | No       | `null`     | Timestamp of premium purchase                 |
| `@HiveField(6)` | `language`             | `String`    | Yes      | `"en"`     | Locale code                                   |
| `@HiveField(7)` | `isFirstLaunch`        | `bool`      | Yes      | `true`     | First-launch flag for onboarding              |

### Default Values (New Installation)

```
Key: "user_settings"
Value: UserSettingsModel(
  themeMode: "system",
  notificationsEnabled: true,
  notificationTime: "20:00",
  skipWeekends: false,
  isPremium: false,
  premiumPurchasedAt: null,
  language: "en",
  isFirstLaunch: true,
)
```

### Serialization (JSON)

```json
{
  "themeMode": "system",
  "notificationsEnabled": true,
  "notificationTime": "20:00",
  "skipWeekends": false,
  "isPremium": false,
  "premiumPurchasedAt": null,
  "language": "en",
  "isFirstLaunch": true
}
```

---

## Type Adapter Registration

Hive TypeAdapters are registered during database initialization, before any box is opened.

| Type ID | Adapter Class              | Model Class         | Registration Check            |
| ------- | -------------------------- | ------------------- | ----------------------------- |
| `0`     | `HabitModelAdapter`        | `HabitModel`        | `Hive.isAdapterRegistered(0)` |
| `1`     | `HabitLogModelAdapter`     | `HabitLogModel`     | `Hive.isAdapterRegistered(1)` |
| `2`     | `UserSettingsModelAdapter` | `UserSettingsModel` | `Hive.isAdapterRegistered(2)` |
| `3–9`   | —                          | —                   | Reserved for future models    |

Adapters are auto-generated via `build_runner` (see `.g.dart` files).

---

## Data Relationships

```
┌──────────────┐       1 : N       ┌──────────────────┐
│   habits     │ ──────────────>>  │   habit_logs     │
│              │                   │                  │
│  PK: id      │                   │  FK: habitId     │
│              │                   │  PK: composite   │
│              │                   │      key         │
└──────────────┘                   └──────────────────┘

┌──────────────┐
│   settings   │   (singleton — always 1 record)
│              │
│  PK: "user_  │
│   settings"  │
└──────────────┘
```

- **habits → habit_logs:** One-to-many. Each habit can have many daily logs. When a habit is deleted, all its logs are cascade-deleted (manual cleanup by key prefix).
- **settings:** Standalone singleton. No foreign keys.

---

## Data Normalization Rules

| Rule                 | Detail                                                                                         |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| Date normalization   | All `HabitLog.date` values are normalized to midnight UTC via `DateTime.utc(year, month, day)` |
| Composite key format | `"{habitId}_{YYYY-MM-DD}"` — extracted from `date.toIso8601String().split('T')[0]`             |
| Active days encoding | Integer list where 1=Monday through 7=Sunday (ISO 8601 weekday numbering)                      |
| Color format         | Hex string with `#` prefix (e.g., `#6C63FF`)                                                   |
| Time format          | 24-hour `HH:mm` string (e.g., `20:00` for 8 PM)                                                |
| Theme mode values    | Enum-like string: `system`, `light`, `dark`, `amoled`                                          |
| Language values      | ISO 639-1 codes: `en`, `hi`, etc.                                                              |

---

## Storage Limits & Constraints

| Constraint             | Value                   | Enforced At                 |
| ---------------------- | ----------------------- | --------------------------- |
| Max habits (free tier) | 10                      | Presentation layer          |
| Max habits (premium)   | 100                     | Presentation layer          |
| Max habit name length  | 50 characters           | Use case layer (validation) |
| Min habit name length  | 1 character             | Use case layer (validation) |
| Active days range      | 1–7                     | Use case layer (validation) |
| Active days minimum    | 1 day selected          | Use case layer (validation) |
| Max logs displayed     | 90 days (calendar view) | Presentation layer          |
| Streak lookback limit  | 365 days                | Value object (Streak)       |

---

## Database Lifecycle

| Operation        | Method                          | Description                                      |
| ---------------- | ------------------------------- | ------------------------------------------------ |
| Initialize       | `HiveDatabase.init()`           | Calls `Hive.initFlutter()`, registers adapters   |
| Open boxes       | `HiveDatabase.openBoxes()`      | Opens all three boxes; idempotent                |
| Close boxes      | `HiveDatabase.closeBoxes()`     | Closes all open boxes                            |
| Clear all data   | `HiveDatabase.clearAllData()`   | Clears contents of all boxes (boxes remain open) |
| Delete all boxes | `HiveDatabase.deleteAllBoxes()` | Closes and deletes box files from disk           |

---

## Backup & Export

| Feature               | Format                         | Content                                                  |
| --------------------- | ------------------------------ | -------------------------------------------------------- |
| Data export (premium) | CSV / PDF                      | Habit names, completion dates, streak data               |
| JSON serialization    | JSON (`toMap()` / `fromMap()`) | Full model data; available on all models for future sync |
| File prefix           | `habit_tracker_export`         | Used for exported file naming                            |
| Date format           | `yyyy-MM-dd`                   | ISO format for export dates                              |
