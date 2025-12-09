class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() => 'AppException: $message\nOriginal error: $originalError';
}

class NetworkException extends AppException {
  final int? statusCode;
  final dynamic response;

  NetworkException(
    String message, {
    this.statusCode,
    this.response,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);

  @override
  String toString() =>
      'NetworkException: $message\nStatus code: $statusCode\nResponse: $response';
}

class HttpException extends NetworkException {
  HttpException(
    String message, {
    int? statusCode,
    dynamic response,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         response: response,
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException(
    String message, {
    int? statusCode = 401,
    dynamic response,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
         message,
         statusCode: statusCode,
         response: response,
         originalError: originalError,
         stackTrace: stackTrace,
       );
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException(
    String message, {
    this.errors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);

  @override
  String toString() => 'ValidationException: $message\nErrors: $errors';
}
