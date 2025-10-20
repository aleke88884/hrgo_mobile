import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hrgo_app/common/constants.dart';
import 'package:hrgo_app/core/secure_storage/secure_storage_service.dart';

class LeaveService {
  final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  static const String _endpoint = '/send_request?model=hr.leave.request';

  LeaveService({Dio? dio}) : _dio = dio ?? Dio();

  /// Создание запроса на отпуск
  ///
  /// [requestType] - тип отпуска: "paid" (оплачиваемый) или "unpaid" (неоплачиваемый)
  /// [base] - базовый тип отпуска, например: "Annual-leave", "Sick-leave"
  /// [dateFrom] - дата начала в формате YYYY-MM-DD
  /// [dateTo] - дата окончания в формате YYYY-MM-DD
  /// [employeeId] - ID сотрудника
  Future<LeaveResponse> createLeaveRequest({
    required String requestType,
    required String base,
    required String dateFrom,
    required String dateTo,
    required int employeeId,
  }) async {
    try {
      // Получаем сохранённые данные авторизации
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

      // Формируем URL
      final url = 'http://$domain$_endpoint';

      // Формируем тело запроса согласно документации
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

      // Отправляем запрос
      final response = await _dio.post(
        url,
        data: jsonEncode(body),
        options: Options(
          headers: {'api-key': apiKey, 'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Обрабатываем ответ
      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data.containsKey('New resource')) {
          return LeaveResponse.fromJson(data);
        } else {
          throw LeaveException('Неожиданный формат ответа от сервера');
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
        throw LeaveException('Недостаточно прав для создания заявки на отпуск');
      } else if (response.statusCode == 404) {
        throw LeaveException('API endpoint не найден');
      } else {
        throw LeaveException('Ошибка сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw LeaveException('Превышено время ожидания соединения');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw LeaveException('Превышено время ожидания ответа');
      } else if (e.type == DioExceptionType.connectionError) {
        throw LeaveException('Ошибка подключения к серверу');
      }

      final errorMessage =
          e.response?.data?['error']?.toString() ??
          e.response?.data?['message']?.toString() ??
          e.message ??
          'Неизвестная ошибка сети';

      throw LeaveException(errorMessage);
    } on LeaveException {
      rethrow;
    } catch (e) {
      throw LeaveException('Непредвиденная ошибка: ${e.toString()}');
    }
  }
}

/// Модель успешного ответа от API
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

      // Парсинг employee_id, который приходит как массив [id, "name"]
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

  /// Конвертация в JSON (для сохранения или логирования)
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
  String toString() {
    return 'LeaveResponse(id: $id, requestType: $requestType, base: $base, '
        'dateFrom: $dateFrom, dateTo: $dateTo, employeeId: $employeeId, '
        'employeeName: $employeeName)';
  }
}

/// Кастомное исключение для операций с отпусками
class LeaveException implements Exception {
  final String message;

  LeaveException(this.message);

  @override
  String toString() => message;
}
