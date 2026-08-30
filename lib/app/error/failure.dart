// Dart imports:
import 'dart:developer' as developer;

/// Something that went wrong below the presentation layer.
///
/// [cause] is kept alongside [message] so a caller can tell one kind of
/// failure apart from another; the message on its own is only fit for a log
/// line.
class Failure {
  Failure({required this.message, this.cause, this.stackTrace});

  final String message;

  /// The error this was built from, where there was one.
  final Object? cause;

  final StackTrace? stackTrace;

  @override
  String toString() => 'Failure: $message';
}

/// Builds a [Failure] for [operation] and writes it to the log.
///
/// Every caller of the repositories either supplies a default or only tests
/// `isLeft`, so without this the message would be built and immediately
/// discarded, leaving a store that could not be read indistinguishable from an
/// empty one — in the field as well as in a debug session.
Failure reportFailure(
  String operation,
  Object error, [
  StackTrace? stackTrace,
]) {
  developer.log(
    '$operation failed',
    name: 'rice_tracker',
    error: error,
    stackTrace: stackTrace,
  );

  return Failure(
    message: error.toString(),
    cause: error,
    stackTrace: stackTrace,
  );
}
