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
      // Очистим возможные http/https
      var cleanDomain = domenUrl.trim();
      if (cleanDomain.startsWith('http')) {
        cleanDomain = cleanDomain.replaceAll(RegExp(r'^https?://'), '');
      }

      // Формируем URL
      final fullUrl = 'http://$cleanDomain$_authEndpoint';

      // Отправляем GET-запрос с логином и паролем в headers
      final response = await _dio.get(
        fullUrl,
        options: Options(headers: {'login': login, 'password': password}),
      );

      // Проверим HTTP статус
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw AuthException('Неизвестная ошибка ');
      }

      // Приведём response.data к Map<String, dynamic> безопасно
      final dynamic rawData = response.data;
      Map<String, dynamic>? jsonData;

      if (rawData == null) {
        throw AuthException('Неизвестная ошибка ');
      } else if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map<String, dynamic>) {
            jsonData = decoded;
          } else {
            throw AuthException('Неизвестная ошибка');
          }
        } catch (e) {
          throw AuthException('Неизвестная ошибка');
        }
      } else {
        // Иногда Dio может вернуть List или другие типы — обработаем как ошибку
        throw AuthException('Неизвестная ошибка');
      }

      // Проверим поле Status
      final statusValue = jsonData['Status'];
      if (statusValue is String &&
          statusValue.toLowerCase() == 'auth successful') {
        final authResponse = AuthResponse.fromJson(jsonData);

        // Сохраняем api-key и домен
        await _storage.writeData(
          authResponse.apiKey,
          Constants.apikeyStorageKey,
        );
        await _storage.writeData(cleanDomain, Constants.domainStorageKey);
        await _storage.writeData(
          '${authResponse.employeeId}',
          Constants.employeeIdStorageKey,
        );
        return authResponse;
      } else {
        // Попробуем получить сообщение ошибки из ответа
        final serverMessage =
            jsonData['message'] ??
            jsonData['error'] ??
            jsonData['Status'] ??
            'Неверный логин или пароль';
        throw AuthException(serverMessage.toString());
      }
    } on DioException catch (e) {
      // Попытка извлечь человекочитаемое сообщение из ответа
      String? message = 'Ошибка сети';
      final respData = e.response?.data;
      if (respData != null) {
        if (respData is Map) {
          message =
              respData['message']?.toString() ??
              respData['error']?.toString() ??
              respData['Status']?.toString() ??
              e.message;
        } else if (respData is String) {
          // иногда приходит строка с описанием ошибки
          message = respData;
        } else {
          message = e.message ?? 'Ошибка сети';
        }
      } else {
        message = e.message ?? 'Ошибка сети';
      }
      throw AuthException(message ?? 'Ошибка сети');
    } catch (e) {
      throw AuthException('Ошибка авторизации: $e');
    }
  }
}

class AuthResponse {
  final String status;
  final String user;
  final String apiKey;
  final int employeeId;
  final String departmentName;
  final String jobName;

  AuthResponse({
    required this.status,
    required this.user,
    required this.apiKey,
    required this.employeeId,
    required this.departmentName,
    required this.jobName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['Status'] ?? '',
      user: json['User'] ?? '',
      apiKey: json['api-key'] ?? '',
      employeeId: json['employee_id'] is int
          ? json['employee_id'] as int
          : int.tryParse('${json['employee_id']}') ?? 0,
      departmentName: json['department_name'] ?? '',
      jobName: json['job_name'] ?? '',
    );
  }
}

/// Исключение для ошибок авторизации
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
