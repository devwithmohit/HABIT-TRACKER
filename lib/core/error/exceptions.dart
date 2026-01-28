/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AppException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Storage/Database exceptions
class StorageException extends AppException {
  StorageException(super.message, [super.stackTrace]);

  factory StorageException.saveError(String details) {
    return StorageException('Failed to save data: $details');
  }

  factory StorageException.loadError(String details) {
    return StorageException('Failed to load data: $details');
  }

  factory StorageException.deleteError(String details) {
    return StorageException('Failed to delete data: $details');
  }

  factory StorageException.initializationError(String details) {
    return StorageException('Failed to initialize storage: $details');
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  ValidationException(super.message, [super.stackTrace]);

  factory ValidationException.invalidInput(String fieldName) {
    return ValidationException('Invalid input for $fieldName');
  }

  factory ValidationException.missingRequired(String fieldName) {
    return ValidationException('Required field missing: $fieldName');
  }
}

/// Network exceptions (for future sync features)
class NetworkException extends AppException {
  NetworkException(super.message, [super.stackTrace]);

  factory NetworkException.connectionFailed() {
    return NetworkException('Network connection failed');
  }

  factory NetworkException.timeout() {
    return NetworkException('Network request timeout');
  }

  factory NetworkException.serverError(int statusCode) {
    return NetworkException('Server error: $statusCode');
  }
}

/// Permission exceptions
class PermissionException extends AppException {
  PermissionException(super.message, [super.stackTrace]);

  factory PermissionException.denied(String permission) {
    return PermissionException('Permission denied: $permission');
  }

  factory PermissionException.permanentlyDenied(String permission) {
    return PermissionException('Permission permanently denied: $permission');
  }
}

/// Monetization exceptions
class MonetizationException extends AppException {
  MonetizationException(super.message, [super.stackTrace]);

  factory MonetizationException.purchaseError(String details) {
    return MonetizationException('Purchase error: $details');
  }

  factory MonetizationException.adError(String details) {
    return MonetizationException('Ad error: $details');
  }

  factory MonetizationException.notInitialized() {
    return MonetizationException('Monetization service not initialized');
  }
}

/// Not found exceptions
class NotFoundException extends AppException {
  NotFoundException(super.message, [super.stackTrace]);

  factory NotFoundException.resource(String resourceName) {
    return NotFoundException('$resourceName not found');
  }
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException(super.message, [super.stackTrace]);

  factory CacheException.readError() {
    return CacheException('Failed to read from cache');
  }

  factory CacheException.writeError() {
    return CacheException('Failed to write to cache');
  }

  factory CacheException.clearError() {
    return CacheException('Failed to clear cache');
  }
}
