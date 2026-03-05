/// Exceções personalizadas para o serviço de instância única
class SingleInstanceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  SingleInstanceException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'SingleInstanceException($code): $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
  }
}

class LockAcquisitionException extends SingleInstanceException {
  LockAcquisitionException(super.message, {super.code, super.originalError});
}

class LockReleaseException extends SingleInstanceException {
  LockReleaseException(super.message, {super.code, super.originalError});
}

class ProcessCheckException extends SingleInstanceException {
  ProcessCheckException(super.message, {super.code, super.originalError});
}
