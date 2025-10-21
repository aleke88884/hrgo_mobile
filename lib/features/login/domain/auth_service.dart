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
        throw AuthException(
          'HTTP ${statusCode.toString()}: ошибка авторизации на сервере',
        );
      }

      // Безопасно приведём response.data к Map<String, dynamic>
      final dynamic rawData = response.data;
      Map<String, dynamic>? jsonData;

      if (rawData == null) {
        throw AuthException('Пустой ответ от сервера');
      } else if (rawData is Map<String, dynamic>) {
        jsonData = rawData;
      } else if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map<String, dynamic>) {
            jsonData = decoded;
          } else {
            throw AuthException('Неподдерживаемый формат ответа сервера');
          }
        } catch (e) {
          throw AuthException('Не смог распарсить ответ сервера: $e');
        }
      } else {
        // Иногда Dio возвращает List или другие типы — обработаем как ошибку
        throw AuthException(
          'Неподдерживаемый формат ответа сервера: ${rawData.runtimeType}',
        );
      }

      // Проверим поле Status — допускаем как строку, так и булево
      final statusValue = _getValue(jsonData, ['Status', 'status']);
      final bool isAuthSuccess = _isStatusSuccess(statusValue);

      if (isAuthSuccess) {
        final authResponse = AuthResponse.fromJson(jsonData);

        // Сохраняем api-key и домен (только если они не пустые)
        if (authResponse.apiKey.isNotEmpty) {
          await _storage.writeData(
            authResponse.apiKey,
            Constants.apikeyStorageKey,
          );
        }
        await _storage.writeData(cleanDomain, Constants.domainStorageKey);
        if (authResponse.employeeId != 0) {
          await _storage.writeData(
            '${authResponse.employeeId}',
            Constants.employeeIdStorageKey,
          );
        }
        return authResponse;
      } else {
        // Попробуем получить сообщение ошибки из ответа
        final serverMessage =
            _getValue(jsonData, [
              'message',
              'error',
              'Message',
              'Status',
              'status',
            ]) ??
            'Неверный логин или пароль';
        throw AuthException(serverMessage.toString());
      }
    } on DioException catch (e) {
      // Попытка извлечь человекочитаемое сообщение из ответа
      String message = 'Ошибка сети';
      final respData = e.response?.data;
      if (respData != null) {
        if (respData is Map) {
          message =
              _getValue(respData as Map<String, dynamic>, [
                'message',
                'error',
                'Status',
                'status',
              ]) ??
              e.message ??
              'Ошибка сети';
        } else if (respData is String) {
          message = respData;
        } else {
          message = e.message ?? 'Ошибка сети';
        }
      } else {
        message = e.message ?? 'Ошибка сети';
      }
      throw AuthException(message);
    } catch (e) {
      throw AuthException('Ошибка авторизации: $e');
    }
  }

  // Помощник: проверяет статус; допускает string "auth successful" (регистронезависимо)
  // и boolean true
  bool _isStatusSuccess(dynamic statusValue) {
    if (statusValue == null) return false;
    if (statusValue is bool) return statusValue == true;
    final s = statusValue.toString().toLowerCase();
    return s == 'auth successful' || s == 'success' || s == 'ok' || s == 'true';
  }

  // Помощник: безопасно ищет первое непустое значение из списка ключей (case-insensitive)
  dynamic _getValue(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      if (json.containsKey(k)) return json[k];
      // попробуем несколько преобразований ключа
      final lower = k.toLowerCase();
      if (json.containsKey(lower)) return json[lower];
      final snake = k.replaceAll('-', '_');
      if (json.containsKey(snake)) return json[snake];
      final kebab = k.replaceAll('_', '-');
      if (json.containsKey(kebab)) return json[kebab];
    }
    // также попробуем найти похожие ключи (без строгого соответствия)
    for (final entry in json.entries) {
      final ek = entry.key.toString().toLowerCase();
      for (final k in keys) {
        if (ek == k.toLowerCase()) return entry.value;
      }
    }
    return null;
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
    // Вспомогательная лямбда: безопасно получить строку из любого типа
    String safeString(dynamic v) {
      if (v == null) return '';
      if (v is String) return v;
      if (v is bool) return v ? 'true' : 'false';
      return v.toString();
    }

    // Поля, которые мы пытаемся достать (учитываем разные варианты имён)
    final status = safeString(_firstPresent(json, ['Status', 'status']));
    final user = safeString(
      _firstPresent(json, ['User', 'user', 'username', 'name']),
    );
    final apiKey = safeString(
      _firstPresent(json, ['api-key', 'api_key', 'apikey', 'Api-Key']),
    );
    final employeeRaw = _firstPresent(json, [
      'employee_id',
      'employeeId',
      'employee',
    ]);
    int employeeId = 0;
    if (employeeRaw is int) {
      employeeId = employeeRaw;
    } else if (employeeRaw is String) {
      employeeId = int.tryParse(employeeRaw) ?? 0;
    } else if (employeeRaw != null) {
      employeeId = int.tryParse(employeeRaw.toString()) ?? 0;
    }

    final departmentName = safeString(
      _firstPresent(json, ['department_name', 'departmentName', 'department']),
    );
    final jobName = safeString(
      _firstPresent(json, ['job_name', 'jobName', 'job']),
    );

    return AuthResponse(
      status: status,
      user: user,
      apiKey: apiKey,
      employeeId: employeeId,
      departmentName: departmentName,
      jobName: jobName,
    );
  }

  // Найти первое совпадение ключей
  static dynamic _firstPresent(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      if (json.containsKey(k)) return json[k];
      final lower = k.toLowerCase();
      if (json.containsKey(lower)) return json[lower];
      final snake = k.replaceAll('-', '_');
      if (json.containsKey(snake)) return json[snake];
      final kebab = k.replaceAll('_', '-');
      if (json.containsKey(kebab)) return json[kebab];
    }
    // fallback: ищем ключ с близким названием
    for (final entry in json.entries) {
      final ek = entry.key.toString().toLowerCase();
      for (final k in keys) {
        if (ek == k.toLowerCase()) return entry.value;
      }
    }
    return null;
  }
}

/// Исключение для ошибок авторизации
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
