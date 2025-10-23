import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hrgo_app/common/constants.dart';
import 'package:hrgo_app/core/secure_storage/secure_storage_service.dart';

class DocumentService {
  final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  static const String _endpoint = '/read_document';
  static const String _signEndpoint = '/sign_document';
  DocumentService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false, // не логируем PDF
        requestHeader: true,
        error: true,
      ),
    );
  }
  // В DocumentService

  Future<String> signDocument({
    required String documentId,
    required String documentModel,
  }) async {
    try {
      final apiKey = await _storage.readData(Constants.apikeyStorageKey);
      final userLogin = await _storage.readData(Constants.userLogin);
      final userPassword = await _storage.readData(Constants.userPassword);

      final fullUrl =
          'http://api-dev.hrgo.kz$_signEndpoint?model=$documentModel&Id=$documentId';

      print('✍️ Запрос подписи: $fullUrl');

      final response = await _dio.post(
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

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final vlink = data['vlink'] as String?;
        if (vlink == null) {
          throw DocumentException('Не удалось получить ссылку на подписание');
        }
        print('✅ Ссылка для подписания: $vlink');
        return vlink;
      } else {
        throw DocumentException(
          'Ошибка при подписании: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DocumentException('Ошибка сети при подписании: ${e.message}');
    } catch (e) {
      throw DocumentException('Ошибка подписи: $e');
    }
  }

  /// Получение PDF-документа
  Future<String> getDocument({
    required String modelName,
    required int documentId,
  }) async {
    try {
      final apiKey = await _storage.readData(Constants.apikeyStorageKey);

      // Очистим возможные http/https и добавим безопасный https

      final fullUrl =
          'http://api-dev.hrgo.kz$_endpoint?model=$modelName&Id=$documentId';

      print('🌐 Запрос документа: $fullUrl');
      final userLogin = await _storage.readData(Constants.userLogin);
      final userPassword = await _storage.readData(Constants.userPassword);
      final response = await _dio.get(
        fullUrl,
        options: Options(
          headers: {
            'login': userLogin,
            'password': userPassword,
            'api-key': apiKey,
          },
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final statusCode = response.statusCode ?? 0;

      if (statusCode == 200) {
        final bytes = response.data as Uint8List;
        if (bytes.isEmpty) throw DocumentException('Получен пустой документ');

        final filePath = await _savePdfToFile(
          bytes,
          '${modelName.replaceAll('.', '_')}_$documentId.pdf',
        );
        print('✅ Документ сохранён: $filePath');
        return filePath;
      }

      // Обработка известных ошибок
      switch (statusCode) {
        case 301:
        case 302:
          final location = response.headers.value('location');
          throw DocumentException(
            'Сервер перенаправил запрос. Попробуйте использовать HTTPS. ${location ?? ''}',
          );
        case 400:
          throw DocumentException('Неверные параметры запроса');
        case 401:
          throw DocumentException(
            'Ошибка авторизации. Пожалуйста, войдите снова.',
          );
        case 403:
          throw DocumentException('Недостаточно прав для просмотра документа');
        case 404:
          throw DocumentException('Документ не найден');
        default:
          throw DocumentException('Ошибка сервера: $statusCode');
      }
    } on DioException catch (e) {
      final type = e.type;
      if (type == DioExceptionType.connectionTimeout) {
        throw DocumentException('Превышено время ожидания соединения');
      } else if (type == DioExceptionType.receiveTimeout) {
        throw DocumentException('Превышено время ожидания ответа');
      } else if (type == DioExceptionType.connectionError) {
        throw DocumentException('Ошибка подключения к серверу');
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

      throw DocumentException(message);
    } catch (e) {
      throw DocumentException('Ошибка получения документа: $e');
    }
  }

  /// Сохранение PDF во временную директорию
  Future<String> _savePdfToFile(Uint8List bytes, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(bytes);
      if (await file.exists()) {
        print('✅ File exists at: $path, size: ${await file.length()} bytes');
        return path;
      } else {
        throw DocumentException('File was not created at: $path');
      }
    } catch (e) {
      throw DocumentException('Error saving file: $e');
    }
  }

  /// Удаление временного файла
  Future<void> deleteTemporaryFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Временный файл удалён: $filePath');
      }
    } catch (e) {
      print('⚠️ Ошибка удаления файла: $e');
    }
  }
}

class DocumentException implements Exception {
  final String message;
  DocumentException(this.message);

  @override
  String toString() => message;
}
