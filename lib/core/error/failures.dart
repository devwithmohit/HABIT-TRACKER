/// Base class for all failures in the application
/// Used for error handling without throwing exceptions
sealed class Failure {
  final String message;
  final Exception? exception;

  const Failure(this.message, [this.exception]);

  @override
  String toString() => message;
}

/// Database/Storage related failures
class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.exception]);

  factory StorageFailure.unableToSave() {
    return const StorageFailure('Unable to save data to storage');
  }

  factory StorageFailure.unableToLoad() {
    return const StorageFailure('Unable to load data from storage');
  }

  factory StorageFailure.unableToDelete() {
    return const StorageFailure('Unable to delete data from storage');
  }

  factory StorageFailure.corruptedData() {
    return const StorageFailure('Storage data is corrupted');
  }
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.exception]);

  factory ValidationFailure.emptyField(String fieldName) {
    return ValidationFailure('$fieldName cannot be empty');
  }

  factory ValidationFailure.invalidFormat(String fieldName) {
    return ValidationFailure('Invalid format for $fieldName');
  }

  factory ValidationFailure.tooShort(String fieldName, int minLength) {
    return ValidationFailure('$fieldName must be at least $minLength characters');
  }

  factory ValidationFailure.tooLong(String fieldName, int maxLength) {
    return ValidationFailure('$fieldName must be at most $maxLength characters');
  }
}

/// Network related failures (for future sync features)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.exception]);

  factory NetworkFailure.noConnection() {
    return const NetworkFailure('No internet connection');
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure('Connection timeout');
  }

  factory NetworkFailure.serverError() {
    return const NetworkFailure('Server error occurred');
  }
}

/// Permission failures (for notifications, storage)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.exception]);

  factory PermissionFailure.notificationsDenied() {
    return const PermissionFailure('Notification permission denied');
  }

  factory PermissionFailure.storageDenied() {
    return const PermissionFailure('Storage permission denied');
  }
}

/// Monetization failures (IAP, Ads)
class MonetizationFailure extends Failure {
  const MonetizationFailure(super.message, [super.exception]);

  factory MonetizationFailure.purchaseFailed() {
    return const MonetizationFailure('Purchase failed');
  }

  factory MonetizationFailure.purchaseCancelled() {
    return const MonetizationFailure('Purchase was cancelled');
  }

  factory MonetizationFailure.productNotAvailable() {
    return const MonetizationFailure('Product not available');
  }

  factory MonetizationFailure.adLoadFailed() {
    return const MonetizationFailure('Failed to load advertisement');
  }
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.exception]);

  factory NotFoundFailure.habit() {
    return const NotFoundFailure('Habit not found');
  }

  factory NotFoundFailure.log() {
    return const NotFoundFailure('Log not found');
  }

  factory NotFoundFailure.settings() {
    return const NotFoundFailure('Settings not found');
  }
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.exception]);

  factory UnexpectedFailure.unknown([Exception? exception]) {
    return UnexpectedFailure('An unexpected error occurred', exception);
  }
}
