/// Exceções personalizadas para o serviço de armazenamento
class StorageException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  StorageException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'StorageException($code): $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
  }
}

class FileAccessException extends StorageException {
  FileAccessException(super.message, {super.code, super.originalError});
}

class JsonParseException extends StorageException {
  JsonParseException(super.message, {super.code, super.originalError});
}

class DirectoryCreationException extends StorageException {
  DirectoryCreationException(super.message, {super.code, super.originalError});
}

class StorageNotFoundException extends StorageException {
  StorageNotFoundException(super.message, {super.code, super.originalError});
}
