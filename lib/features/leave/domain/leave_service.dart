import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hrgo_app/common/constants.dart';
import 'package:hrgo_app/core/secure_storage/secure_storage_service.dart';

class LeaveService {
  final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  static const String _endpoint = '/send_request?model=hr.leave.request';

  LeaveService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        error: true,
      ),
    );
  }

  Future<LeaveResponse> createLeaveRequest({
    required String requestType,
    required String base,
    required String dateFrom,
    required String dateTo,
    required int employeeId,
  }) async {
    try {
      final domain = await _storage.readData(Constants.domainStorageKey);
      final apiKey = await _storage.readData(Constants.apikeyStorageKey);

      if (domain == null || domain.isEmpty) {
        throw LeaveException(
          'Домен не найден. Пожалуйста, авторизуйтесь снова.',
        );
      }

      if (apiKey == null || apiKey.isEmpty) {
        throw LeaveException(
          'API-ключ не найден. Пожалуйста, авторизуйтесь снова.',
        );
      }

      final cleanDomain = domain.trim();
      final url = 'http://$cleanDomain:8069$_endpoint';

      final body = {
        "fields": [
          "request_type",
          "base",
          "date_from",
          "date_to",
          "employee_id",
        ],
        "values": {
          "request_type": requestType,
          "base": base,
          "date_from": dateFrom,
          "date_to": dateTo,
          "employee_id": employeeId,
        },
      };

      final response = await _dio.post(
        url,
        // ❌ не нужно jsonEncode — Dio сам сериализует в JSON
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'api-key': apiKey,
            'login': 'test',
            'password': 'test',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        dynamic data = response.data;

        // Иногда Dio возвращает строку, поэтому явно декодируем при необходимости
        if (data is String) {
          data = jsonDecode(data);
        }

        if (data is Map<String, dynamic> && data.containsKey('New resource')) {
          return LeaveResponse.fromJson(data);
        } else {
          throw LeaveException('Неожиданный формат ответа от сервера: $data');
        }
      } else if (response.statusCode == 400) {
        final error =
            response.data?['error'] ??
            response.data?['message'] ??
            'Неверные данные запроса';
        throw LeaveException('Ошибка валидации: $error');
      } else if (response.statusCode == 401) {
        throw LeaveException('Ошибка авторизации. Пожалуйста, войдите снова.');
      } else if (response.statusCode == 403) {
        throw LeaveException(
          'Недостаточно прав для создания заявки на отпуск.',
        );
      } else if (response.statusCode == 404) {
        throw LeaveException('API endpoint не найден.');
      } else {
        throw LeaveException('Ошибка сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?.toString() ?? e.message ?? 'Ошибка сети';
      throw LeaveException(errorMessage);
    } catch (e) {
      throw LeaveException('Непредвиденная ошибка: ${e.toString()}');
    }
  }
}

class LeaveResponse {
  final int id;
  final String requestType;
  final String base;
  final String dateFrom;
  final String dateTo;
  final int employeeId;
  final String employeeName;

  LeaveResponse({
    required this.id,
    required this.requestType,
    required this.base,
    required this.dateFrom,
    required this.dateTo,
    required this.employeeId,
    required this.employeeName,
  });

  factory LeaveResponse.fromJson(Map<String, dynamic> json) {
    try {
      final resourcesList = json['New resource'];
      if (resourcesList == null ||
          resourcesList is! List ||
          resourcesList.isEmpty) {
        throw LeaveException('Пустой ответ от сервера');
      }

      final data = resourcesList.first as Map<String, dynamic>;
      final employeeData = data['employee_id'];

      int empId = 0;
      String empName = '';

      if (employeeData is List && employeeData.isNotEmpty) {
        empId = employeeData[0] is int
            ? employeeData[0]
            : int.tryParse(employeeData[0].toString()) ?? 0;
        empName = employeeData.length > 1 ? employeeData[1].toString() : '';
      } else if (employeeData is int) {
        empId = employeeData;
      }

      return LeaveResponse(
        id: data['id'] ?? 0,
        requestType: data['request_type']?.toString() ?? '',
        base: data['base']?.toString() ?? '',
        dateFrom: data['date_from']?.toString() ?? '',
        dateTo: data['date_to']?.toString() ?? '',
        employeeId: empId,
        employeeName: empName,
      );
    } catch (e) {
      throw LeaveException('Ошибка парсинга ответа: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'request_type': requestType,
    'base': base,
    'date_from': dateFrom,
    'date_to': dateTo,
    'employee_id': employeeId,
    'employee_name': employeeName,
  };

  @override
  String toString() =>
      'LeaveResponse(id: $id, requestType: $requestType, base: $base, dateFrom: $dateFrom, dateTo: $dateTo, employeeId: $employeeId, employeeName: $employeeName)';
}

class LeaveException implements Exception {
  final String message;
  LeaveException(this.message);
  @override
  String toString() => message;
}
