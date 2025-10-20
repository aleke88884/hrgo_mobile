import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Сервис для безопасного хранения данных (API-ключ, токены, логин и т.д.)
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }
}
