Tech Stack: Habit Tracker
Frontend (Cross-platform)
Flutter (Dart)

Single codebase → iOS + Android
Native performance
Material + Cupertino widgets built-in
Fast rebuild times
Strong offline-first support

Local Database
Hive (NoSQL, key-value)

Pure Dart, no native dependencies
Fast read/write
Encrypted boxes for premium features
Zero setup
Perfect for habit streaks + timestamps

State Management
Riverpod 2.x

Type-safe
No boilerplate
Easy testing
Clean architecture patterns

Notifications
flutter_local_notifications

Cross-platform local scheduling
No backend needed
Timezone-aware

Monetization
google_mobile_ads (AdMob)
in_app_purchase (IAP)

Official Flutter plugins
Handles iOS + Android billing

Analytics (Optional)
Firebase Analytics (free tier)

Track retention, feature usage
Crash reporting via Crashlytics
No PII needed

Why This Stack?
RequirementSolutionOffline-firstHive + FlutterFast devSingle codebaseNo backendLocal storage onlyClean UIFlutter widgetsLow costFree tier everywhereProduction-readyBattle-tested plugins

What You DON'T Need
❌ Supabase / Firebase DB (local-first = no sync)
❌ React Native (slower, bridge overhead)
❌ Native Swift/Kotlin (2x dev time)
❌ GraphQL / REST API (no backend!)
