class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Error del servidor']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Sin conexión a internet']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Error en caché local']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Error de autenticación']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Recurso no encontrado']);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Error de validación']);
}
