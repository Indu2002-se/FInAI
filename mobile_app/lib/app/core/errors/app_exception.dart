abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class ForbiddenException extends AppException {
  ForbiddenException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class NotFoundException extends AppException {
  NotFoundException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class BadRequestException extends AppException {
  BadRequestException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class TimeoutException extends AppException {
  TimeoutException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required super.message,
    this.errors,
    super.code,
    super.originalException,
  });
}

class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
    super.originalException,
  });
}

class UnknownException extends AppException {
  UnknownException({
    required super.message,
    super.code,
    super.originalException,
  });
}
