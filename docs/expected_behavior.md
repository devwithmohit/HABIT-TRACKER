# Expected Behavior — Habit Tracker App

---

## 1. App Launch & Initialization

| Step                 | Expected Behavior                                                                                                                       |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Cold start           | Flutter binding initializes → Hive database initializes → Type adapters register → Hive boxes open (`habits`, `habit_logs`, `settings`) |
| Notification service | Initializes `flutter_local_notifications` plugin; silently skipped on web                                                               |
| Ad service           | Initializes Google Mobile Ads SDK (skipped on web); loads banner ad                                                                     |
| Purchase service     | Initializes In-App Purchase plugin (skipped on web); begins listening to purchase stream                                                |
| Settings load        | Reads `UserSettings` from Hive; if none exist, creates and persists default settings                                                    |
| Habits load          | Reads all active (non-archived) habits from Hive; calculates streaks for each                                                           |
| First launch         | `isFirstLaunch` flag is `true` on first open; marked `false` after initial load                                                         |
| Theme                | Applied based on `themeMode` setting (`system`, `light`, `dark`, `amoled`)                                                              |
| Home screen          | Displays today's active habits with streak badges; fully functional offline                                                             |

---

## 2. Habit Management

### 2.1 Create Habit

| Condition                              | Expected Behavior                                                                                                                          |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Valid input                            | Habit created with UUID, name (trimmed), icon, color, active days, `createdAt = now`, `isArchived = false`; persisted to `habits` Hive box |
| Empty name                             | Returns `Failure("Habit name cannot be empty")` — habit is NOT created                                                                     |
| No active days selected                | Returns `Failure("Please select at least one active day")` — habit is NOT created                                                          |
| Invalid active day value (outside 1–7) | Returns `Failure("Invalid active days")` — habit is NOT created                                                                            |
| Free tier limit reached                | Enforced at presentation layer; max **10 habits** (free) / **100 habits** (premium)                                                        |
| Success                                | UI rebuilds showing the new habit in the list                                                                                              |

### 2.2 Update Habit

| Condition       | Expected Behavior                                                                             |
| --------------- | --------------------------------------------------------------------------------------------- |
| Valid update    | Existing habit is overwritten in Hive box with new field values                               |
| Habit not found | Returns `Failure("Habit not found")`                                                          |
| Empty name      | Returns `Failure("Habit name cannot be empty")`                                               |
| Partial update  | `updateFields()` loads existing habit, applies only changed fields via `copyWith`, then saves |

### 2.3 Delete Habit

| Condition             | Expected Behavior                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Valid delete          | Habit removed from `habits` box; **all associated logs** (keys starting with `{habitId}_`) removed from `habit_logs` box |
| Habit not found       | Returns `Failure("Habit not found")`                                                                                     |
| Archive (soft delete) | Sets `isArchived = true`; habit excluded from active list but data preserved                                             |
| Unarchive             | Sets `isArchived = false`; habit reappears in active list                                                                |

### 2.4 Reorder Habits

| Condition             | Expected Behavior                                                                                                                                                    |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Reorder request       | Accepts ordered list of habit IDs; returns habits in that order (note: persistent `order` field is a planned future enhancement — currently order is in-memory only) |
| Sort by creation date | Returns habits sorted by `createdAt` ascending or descending                                                                                                         |
| Sort by name          | Returns habits sorted alphabetically by name (case-insensitive)                                                                                                      |

---

## 3. Habit Completion (Logging)

### 3.1 Mark Habit Complete

| Condition                 | Expected Behavior                                                                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| First completion for date | Creates `HabitLog` with `isCompleted = true`, `completedAt = now`, date normalized to midnight UTC; stored with composite key `{habitId}_{YYYY-MM-DD}` |
| Already completed         | Returns `Failure("Habit already completed for this date")` — no duplicate log                                                                          |
| After saving              | Recalculates streak from all logs for that habit; returns updated `Streak`                                                                             |
| Batch complete            | Iterates list of habit IDs, marks each complete for today, returns list of streaks                                                                     |

### 3.2 Unmark Habit Complete

| Condition                    | Expected Behavior                                             |
| ---------------------------- | ------------------------------------------------------------- |
| Existing completed log       | Log is **deleted** from `habit_logs` box; streak recalculated |
| No log for date              | Returns `Failure("No log found for this date")`               |
| Log exists but not completed | Returns `Failure("Habit is not completed for this date")`     |

### 3.3 Toggle Completion

| Condition               | Expected Behavior                                         |
| ----------------------- | --------------------------------------------------------- |
| No existing log         | Creates new completed log                                 |
| Existing completed log  | Toggles `isCompleted` to `false`, clears `completedAt`    |
| Existing incomplete log | Toggles `isCompleted` to `true`, sets `completedAt = now` |
| After toggle            | Streak is recalculated and returned                       |

---

## 4. Streak Calculation

| Rule              | Expected Behavior                                                                                      |
| ----------------- | ------------------------------------------------------------------------------------------------------ |
| Empty logs        | Returns `Streak(current: 0, longest: 0, lastCompletedDate: null, isActiveToday: false)`                |
| No completed logs | Returns empty streak                                                                                   |
| Current streak    | Counts consecutive active-day completions backward from today (or yesterday if not completed today)    |
| Non-active days   | Skipped when counting streak — e.g., if habit is Mon–Fri, weekends don't break the streak              |
| Consecutive check | Two dates are "consecutive" if they are the next active day apart (up to 7-day gap for full week skip) |
| Longest streak    | Calculated from full history; always ≥ current streak                                                  |
| `isActiveToday`   | `true` if there is a completed log for today's normalized date                                         |
| Safety limit      | Streak calculation stops after 365 days lookback                                                       |
| At-risk detection | Habit is "at risk" if: not completed today AND today is an active day AND current streak > 0           |

### Motivational Status Messages

| Streak Length | Status                  |
| ------------- | ----------------------- |
| 0             | "Start your streak!"    |
| 3+            | "Building momentum! 👍" |
| 7+            | "Week streak! ⭐"       |
| 30+           | "Month streak! 🚀"      |
| 90+           | "Quarter year! 🎯"      |
| 180+          | "Half year strong! 💪"  |
| 365+          | "Legendary! 🔥"         |

---

## 5. Analytics & Summaries

### 5.1 Check Habit Due Today

| Query                | Expected Behavior                                                                             |
| -------------------- | --------------------------------------------------------------------------------------------- |
| Single habit         | Returns `true` if today's weekday is in the habit's `activeDays`                              |
| All due today        | Returns list of `HabitWithStreak` for habits active on today's weekday                        |
| Incomplete due today | Filters above list to only habits where `isActiveToday = false`                               |
| Completed today      | Filters to habits where `isActiveToday = true`                                                |
| Today's stats        | Returns `TodayStats` with `totalDue`, `completed`, `remaining`, `completionRate` (percentage) |

### 5.2 Weekly Summary

| Metric               | Expected Behavior                                                 |
| -------------------- | ----------------------------------------------------------------- |
| Week range           | Monday to Sunday of the current week                              |
| Total completions    | Count of all completed logs across all active habits for the week |
| Possible completions | Sum of active days per habit for the week                         |
| Completion rate      | `(totalCompletions / possibleCompletions) * 100`                  |
| Daily completions    | Map of weekday (1–7) → number of completions                      |
| Best day             | Weekday with highest completions                                  |
| Worst day            | Weekday with lowest completions                                   |
| Perfect habits       | Habits that were completed on every active day during the week    |
| No habits            | Returns zeroed-out summary with empty lists                       |

### 5.3 Streak Analytics

| Query          | Expected Behavior                                                                                                                 |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Top streaks    | Returns up to N habits sorted by current streak descending                                                                        |
| At-risk habits | Returns habits due today, not yet completed, with current streak > 0; sorted by streak length descending (highest priority first) |

---

## 6. Calendar View

| Feature             | Expected Behavior                                                      |
| ------------------- | ---------------------------------------------------------------------- |
| Display             | Shows last 90 days of habit completion data                            |
| Completed days      | Visually marked (e.g., filled dot/color) for dates with completed logs |
| Incomplete days     | Distinct visual for active days with no completion                     |
| Non-active days     | Not highlighted or marked                                              |
| Chain visualization | "Don't break the chain" — consecutive completed days appear linked     |

---

## 7. Settings

| Setting               | Expected Behavior                                                                              |
| --------------------- | ---------------------------------------------------------------------------------------------- |
| Theme mode            | `system` (follows OS), `light`, `dark`, `amoled`; persisted immediately; UI rebuilds on change |
| Notifications enabled | Toggle on/off; when enabled, schedules daily notification                                      |
| Notification time     | `HH:mm` format (default: `20:00`); reschedules notification on change                          |
| Skip weekends         | When `true`, notifications only scheduled Mon–Fri                                              |
| Language              | Stored as locale code (`en`, `hi`, etc.)                                                       |
| First launch flag     | Set to `false` after initial setup; read to determine onboarding flow                          |
| Reset to defaults     | Overwrites settings with `UserSettings.defaultSettings()`                                      |

---

## 8. Notifications

| Scenario               | Expected Behavior                                                                                                 |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Daily reminder         | Scheduled at user-configured time using `flutter_local_notifications` with timezone support                       |
| Skip weekends enabled  | Notifications scheduled only for Mon–Fri (individual day-of-week schedules)                                       |
| Skip weekends disabled | Single daily recurring notification at configured time                                                            |
| Notification tap       | App opens; navigates based on payload (future enhancement)                                                        |
| iOS permissions        | Requests alert, badge, sound permissions at initialization                                                        |
| Time passed today      | If configured time already passed, schedules for next valid day                                                   |
| Notification content   | Default title: "Time to check your habits! 🎯"; default body: "Complete today's habits to keep your streak going" |

---

## 9. Monetization

### 9.1 Advertisements (Free Tier)

| Behavior      | Expected                                                          |
| ------------- | ----------------------------------------------------------------- |
| Banner ad     | Loaded via Google Mobile Ads SDK; displayed at bottom of screen   |
| Ad not loaded | UI gracefully hides the ad space                                  |
| Premium users | Ads are not shown                                                 |
| Platform      | Android and iOS only; disabled on web                             |
| Ad unit IDs   | Test IDs used in development; production IDs required for release |

### 9.2 In-App Purchase (Premium)

| Behavior            | Expected                                                                         |
| ------------------- | -------------------------------------------------------------------------------- |
| Product             | Single non-consumable product: `habit_tracker_premium`                           |
| Purchase flow       | Query product → display price → `buyNonConsumable()` → listen to purchase stream |
| Successful purchase | `isPremium` set to `true` in settings; `premiumPurchasedAt` timestamped          |
| Restore purchases   | Calls `restorePurchases()` to recover premium on reinstall (especially iOS)      |
| Premium benefits    | Ad-free, unlimited habits (up to 100), premium themes, data export               |
| Fallback price      | If product query fails, display fallback "₹149"                                  |
| Web platform        | IAP disabled; skipped during initialization                                      |

---

## 10. Error Handling

| Error Category        | Behavior                                                                                                         |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Storage errors        | Caught and wrapped in `StorageFailure` / `Failure` result                                                        |
| Validation errors     | Returned as `Failure` with descriptive message; operation does NOT proceed                                       |
| Not found errors      | Returned as `Failure("Habit not found")` or similar                                                              |
| Monetization errors   | Caught; purchase failures surfaced to UI; ad failures silently handled                                           |
| Initialization errors | Logged to console; non-critical services (notifications, ads, IAP) fail gracefully without crashing the app      |
| All use cases         | Return `Result<T>` — either `Success(data)` or `Failure(message, exception?)` — never throw unhandled exceptions |

---

## 11. Data Flow Summary

```
User Action → UI Widget → Riverpod Provider/Notifier → Use Case → Repository (Interface) → Repository Impl → Hive Database
                                                                                                        ↑
                                                                                               Mapper (Entity ↔ Model)
```

1. **User taps** → Widget calls Provider method
2. **Provider** → Invokes Use Case
3. **Use Case** → Validates input, calls Repository, computes business logic (streaks, summaries)
4. **Repository Impl** → Reads/writes Hive box via Mapper
5. **Mapper** → Converts between Domain Entity and Hive Model
6. **Result** returned up the chain → Provider updates state → UI rebuilds

---

## 12. Offline-First Guarantees

| Guarantee            | Detail                                        |
| -------------------- | --------------------------------------------- |
| No network required  | All features work without internet            |
| No account required  | No signup, login, or authentication           |
| Local persistence    | All data stored in Hive boxes on device       |
| Instant availability | Data available immediately after app launch   |
| No data sync         | No server-side storage (future consideration) |
