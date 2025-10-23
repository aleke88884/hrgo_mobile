import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hrgo_app/common/constants.dart';
import 'package:hrgo_app/core/secure_storage/secure_storage_service.dart';

class EmployeeDocumentsService {
  final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  static const String _baseUrl = 'http://api-dev.hrgo.kz';
  static const String _endpoint = '/send_request';

  EmployeeDocumentsService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        error: true,
      ),
    );
  }

  /// Получение списка документов сотрудника
  Future<EmployeeDocumentsResponse> getEmployeeDocuments({
    required int employeeId,
  }) async {
    try {
      final apiKey = await _storage.readData(Constants.apikeyStorageKey);
      final userLogin = await _storage.readData(Constants.userLogin);
      final userPassword = await _storage.readData(Constants.userPassword);

      final fullUrl =
          '$_baseUrl$_endpoint'
          '?model=hr.employee'
          '&fields=contract_id,hr_leave_order_ids'
          '&Id=$employeeId';

      print('🌐 Запрос документов сотрудника: $fullUrl');

      final response = await _dio.get(
        fullUrl,
        options: Options(
          headers: {
            'login': userLogin,
            'password': userPassword,
            'api-key': apiKey,
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final statusCode = response.statusCode ?? 0;

      if (statusCode == 200) {
        dynamic data = response.data;
        print('✅ Получены данные: $data');

        // Если data — это строка, попробуем декодировать вручную
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (e) {
            throw DocumentsException('Ошибка парсинга JSON: $e');
          }
        }

        // Убедимся, что это Map
        if (data is! Map<String, dynamic>) {
          throw DocumentsException('Неверный формат ответа от сервера');
        }

        return EmployeeDocumentsResponse.fromJson(data);
      }

      // Обработка известных ошибок
      switch (statusCode) {
        case 400:
          throw DocumentsException('Неверные параметры запроса');
        case 401:
          throw DocumentsException(
            'Ошибка авторизации. Пожалуйста, войдите снова.',
          );
        case 403:
          throw DocumentsException('Недостаточно прав доступа');
        case 404:
          throw DocumentsException('Сотрудник не найден');
        default:
          throw DocumentsException('Ошибка сервера: $statusCode');
      }
    } on DioException catch (e) {
      final type = e.type;
      if (type == DioExceptionType.connectionTimeout) {
        throw DocumentsException('Превышено время ожидания соединения');
      } else if (type == DioExceptionType.receiveTimeout) {
        throw DocumentsException('Превышено время ожидания ответа');
      } else if (type == DioExceptionType.connectionError) {
        throw DocumentsException('Ошибка подключения к серверу');
      }

      final resp = e.response;
      String message = e.message ?? 'Ошибка сети';
      if (resp?.data is Map) {
        final data = resp!.data as Map;
        message =
            data['message']?.toString() ??
            data['error']?.toString() ??
            data['Status']?.toString() ??
            message;
      } else if (resp?.data is String) {
        message = resp!.data;
      }

      throw DocumentsException(message);
    } catch (e) {
      if (e is DocumentsException) rethrow;
      throw DocumentsException('Ошибка получения документов: $e');
    }
  }
}

/// Модель ответа от API
class EmployeeDocumentsResponse {
  final List<DocumentRecord> records;

  EmployeeDocumentsResponse({required this.records});

  factory EmployeeDocumentsResponse.fromJson(Map<String, dynamic> json) {
    final recordsList = json['records'] as List? ?? [];
    return EmployeeDocumentsResponse(
      records: recordsList
          .map((record) => DocumentRecord.fromJson(record))
          .toList(),
    );
  }

  /// Получить все документы в виде плоского списка
  List<DocumentItem> getAllDocuments() {
    final allDocuments = <DocumentItem>[];

    for (final record in records) {
      // Добавляем контракт, если есть
      if (record.contractId != null) {
        allDocuments.add(record.contractId!);
      }

      // Добавляем все приказы на отпуск
      allDocuments.addAll(record.hrLeaveOrderIds);
    }

    return allDocuments;
  }
}

/// Запись о сотруднике с документами
class DocumentRecord {
  final int id;
  final DocumentItem? contractId;
  final List<DocumentItem> hrLeaveOrderIds;

  DocumentRecord({
    required this.id,
    this.contractId,
    required this.hrLeaveOrderIds,
  });

  factory DocumentRecord.fromJson(Map<String, dynamic> json) {
    // Парсинг контракта
    DocumentItem? contract;
    if (json['contract_id'] != null) {
      if (json['contract_id'] is Map) {
        contract = DocumentItem.fromJson(
          json['contract_id'] as Map<String, dynamic>,
          defaultTitle: 'Трудовой договор',
        );
      } else if (json['contract_id'] is String) {
        // Handle case where contract_id is just a string (e.g., ID)
        contract = DocumentItem(
          id: 0, // Use a default ID or parse if needed
          name: json['contract_id'] as String,
          model: 'hr.contract',
          title: 'Трудовой договор',
        );
      }
    }

    // Парсинг приказов на отпуск
    final leaveOrdersRaw = json['hr_leave_order_ids'];
    final List<DocumentItem> leaveOrders = [];

    if (leaveOrdersRaw != null && leaveOrdersRaw is List) {
      for (final order in leaveOrdersRaw) {
        if (order is Map<String, dynamic>) {
          leaveOrders.add(
            DocumentItem.fromJson(order, defaultTitle: 'Приказ на отпуск'),
          );
        } else if (order is String) {
          // Handle case where order is just a string (e.g., ID)
          leaveOrders.add(
            DocumentItem(
              id: 0, // Use a default ID or parse if needed
              name: order,
              model: 'hr.leave.order',
              title: 'Приказ на отпуск',
            ),
          );
        }
      }
    }

    return DocumentRecord(
      id: json['id'] ?? 0,
      contractId: contract,
      hrLeaveOrderIds: leaveOrders,
    );
  }
}

/// Модель документа
class DocumentItem {
  final int id;
  final String name;
  final String? state;
  final String model;
  final String title;

  DocumentItem({
    required this.id,
    required this.name,
    this.state,
    required this.model,
    required this.title,
  });

  factory DocumentItem.fromJson(
    Map<String, dynamic> json, {
    String defaultTitle = 'Документ',
  }) {
    // Формируем читаемое название
    String title = json['name']?.toString() ?? defaultTitle;

    // Добавляем статус к названию, если есть
    if (json['state'] != null) {
      final state = json['state'].toString();
      final stateText = getStateText(state);
      if (stateText.isNotEmpty) {
        title = '$title ($stateText)';
      }
    }

    return DocumentItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      state: json['state']?.toString(),
      model: json['model']?.toString() ?? '',
      title: title,
    );
  }

  /// Получить человекочитаемое название статуса
  static String getStateText(String state) {
    switch (state) {
      case 'under_approval_employee':
        return 'На согласовании у сотрудника';
      case 'approved':
        return 'Утвержден';
      case 'rejected':
        return 'Отклонен';
      case 'draft':
        return 'Черновик';
      default:
        return state;
    }
  }

  /// Иконка в зависимости от типа документа
  String get icon {
    if (model.contains('contract')) return '📄';
    if (model.contains('leave')) return '🏖️';
    return '📋';
  }
}

class DocumentsException implements Exception {
  final String message;
  DocumentsException(this.message);

  @override
  String toString() => message;
}
