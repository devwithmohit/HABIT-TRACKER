/// Result type for use case operations
/// Provides type-safe error handling without exceptions
sealed class Result<T> {
  const Result();
}

/// Success result with data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure result with error
class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;

  const Failure(this.message, [this.exception]);

  @override
  String toString() => 'Failure: $message';
}

/// Extension methods for Result handling
extension ResultExtension<T> on Result<T> {
  /// Check if result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Get error message if failure, null otherwise
  String? get errorOrNull => isFailure ? (this as Failure<T>).message : null;

  /// Transform success data
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(:final data) => Success(transform(data)),
      Failure(:final message, :final exception) => Failure(message, exception),
    };
  }

  /// Execute callback on success
  Result<T> onSuccess(void Function(T data) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// Execute callback on failure
  Result<T> onFailure(void Function(String message) callback) {
    if (this is Failure<T>) {
      callback((this as Failure<T>).message);
    }
    return this;
  }
}
