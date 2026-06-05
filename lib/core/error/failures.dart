import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Thrown when a local storage (Hive) operation fails.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Thrown when a network / remote API call fails.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Thrown when the API key is missing or invalid.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Thrown when the AI provider returns an unexpected payload.
class ParseFailure extends Failure {
  const ParseFailure(super.message);
}
