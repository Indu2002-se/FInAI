abstract class ApiResponse<T> {
  const ApiResponse();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) error,
    required R Function() loading,
  });

  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(String message, String? code)? error,
    R Function()? loading,
  });

  T? getOrNull() {
    return when(
      success: (data) => data,
      error: (_, __) => null,
      loading: () => null,
    );
  }

  String? getErrorOrNull() {
    return whenOrNull(
      error: (message, _) => message,
    );
  }
}

class SuccessResponse<T> extends ApiResponse<T> {
  final T data;

  const SuccessResponse(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) error,
    required R Function() loading,
  }) {
    return success(data);
  }

  @override
  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(String message, String? code)? error,
    R Function()? loading,
  }) {
    return success?.call(data);
  }
}

class ErrorResponse<T> extends ApiResponse<T> {
  final String message;
  final String? code;

  const ErrorResponse({
    required this.message,
    this.code,
  });

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) error,
    required R Function() loading,
  }) {
    return error(message, code);
  }

  @override
  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(String message, String? code)? error,
    R Function()? loading,
  }) {
    return error?.call(message, code);
  }
}

class LoadingResponse<T> extends ApiResponse<T> {
  const LoadingResponse();

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) error,
    required R Function() loading,
  }) {
    return loading();
  }

  @override
  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(String message, String? code)? error,
    R Function()? loading,
  }) {
    return loading?.call();
  }
}
