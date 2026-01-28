// Placeholder for future remote sync functionality
// Currently not needed as app is 100% offline-first

/// Remote data source for habit sync (future feature)
///
/// This can be implemented later if cloud sync is needed
/// Potential implementations:
/// - Firebase Firestore
/// - Supabase
/// - Custom REST API
/// - iCloud/Google Drive file sync
abstract class RemoteSyncDataSource {
  Future<void> syncHabits();
  Future<void> syncLogs();
  Future<void> syncSettings();
}
