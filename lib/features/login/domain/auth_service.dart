import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hrgo_app/common/constants.dart';
import 'package:hrgo_app/core/secure_storage/secure_storage_service.dart';

class AuthApiService {
  final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  static const String _authEndpoint = '/odoo_connect';

  AuthApiService({Dio? dio}) : _dio = dio ?? Dio();

  Future<AuthResponse> login({
    required String login,
    required String password,
    required String domenUrl,
  }) async {
    try {
      // Очистим URL от http/https
      var cleanDomain = domenUrl.trim();
      cleanDomain = cleanDomain.replaceAll(RegExp(r'^https?://'), '');

      final fullUrl = 'http://$cleanDomain$_authEndpoint';

      // Отправляем GET-запрос с заголовками
      final response = await _dio.get(
        fullUrl,
        options: Options(headers: {'login': login, 'password': password}),
      );

      if (response.statusCode != 200) {
        throw AuthException('Ошибка сервера (${response.statusCode})');
      }

      final data = _normalizeResponse(response.data);

      final bool status = data['status'] == true;

      // Ошибка авторизации
      if (!status) {
        final message = data['message'] ?? 'Неверный логин или пароль';
        throw AuthException(message);
      }

      // Успешный ответ
      final authResponse = AuthResponse.fromJson(data);

      // Сохраняем данные в SecureStorage
      await _storage.writeData(cleanDomain, Constants.domainStorageKey);
      await _storage.writeData(authResponse.apiKey, Constants.apikeyStorageKey);
      await _storage.writeData(
        authResponse.employeeId.toString(),
        Constants.employeeIdStorageKey,
      );

      return authResponse;
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Ошибка сети'
          : e.message ?? 'Ошибка сети';
      throw AuthException(message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Map<String, dynamic> _normalizeResponse(dynamic raw) {
    if (raw == null) throw AuthException('Пустой ответ от сервера');
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) return jsonDecode(raw);
    throw AuthException('Некорректный формат ответа');
  }
}

class AuthResponse {
  final bool status;
  final String userName;
  final String apiKey;
  final int employeeId;
  final int userId;

  AuthResponse({
    required this.status,
    required this.userName,
    required this.apiKey,
    required this.employeeId,
    required this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] == true,
      userName: json['user_name']?.toString() ?? '',
      apiKey: json['api_key']?.toString() ?? '',
      employeeId: (json['employee_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
