import 'dart:convert';
import 'dart:typed_data';
import 'package:hrgo_app/common/constants.dart';
import 'package:hrgo_app/core/secure_storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = 'http://api-dev.hrgo.kz';
  final SecureStorageService secureStorageService = SecureStorageService();

  /// Получение профиля сотрудника по ID
  Future<ProfileModel> getEmployeeProfile(int employeeId) async {
    try {
      // 1️⃣ Формируем URL
      final url = Uri.parse(
        '$baseUrl/send_request?model=hr.employee&fields=name,email,department_id,job_id,image_1920&Id=$employeeId',
      );

      final apiKey = await secureStorageService.readData(
        Constants.apikeyStorageKey,
      );
      final userLogin =
          await secureStorageService.readData(Constants.userLogin) ?? 'test';
      final userPassword =
          await secureStorageService.readData(Constants.userPassword) ?? 'test';

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key is missing. Please re-login.');
      }

      // 3️⃣ Отправляем GET-запрос
      final response = await http
          .get(
            url,
            headers: {
              'login': userLogin,
              'password': userPassword,
              'api-key': apiKey,
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Please check your internet connection.',
              );
            },
          );

      // 4️⃣ Обрабатываем ответ
      final decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);

      if (response.statusCode == 200) {
        if (data.containsKey('records') && data['records'] is List) {
          final records = data['records'] as List<dynamic>;
          if (records.isEmpty) throw Exception('Employee profile not found.');
          return ProfileModel.fromJson(records.first);
        } else {
          throw Exception('Invalid response format from server.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please re-login.');
      } else if (response.statusCode == 404) {
        throw Exception('Employee not found.');
      } else {
        throw Exception(
          'Failed to load profile. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Обновление профиля сотрудника
  Future<bool> updateEmployeeProfile(
    int employeeId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final userLogin =
          await secureStorageService.readData(Constants.userLogin) ?? 'test';
      final userPassword =
          await secureStorageService.readData(Constants.userPassword) ?? 'test';
      final apiKey = await secureStorageService.readData(
        Constants.apikeyStorageKey,
      );

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key is missing. Please re-login.');
      }

      final url = Uri.parse('$baseUrl/update_request');

      final response = await http
          .post(
            url,
            headers: {
              'login': userLogin,
              'password': userPassword,
              'api-key': apiKey,
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'model': 'hr.employee',
              'id': employeeId,
              'values': updates,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update profile. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }
}

/// Модель профиля
class ProfileModel {
  final int id;
  final String name;
  final String email;
  final List<dynamic> departmentId;
  final List<dynamic> jobId;
  final String? image1920;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.departmentId,
    required this.jobId,
    this.image1920,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      departmentId: json['department_id'] is List
          ? List<dynamic>.from(json['department_id'])
          : [],
      jobId: json['job_id'] is List ? List<dynamic>.from(json['job_id']) : [],
      image1920: json['image_1920']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'department_id': departmentId,
    'job_id': jobId,
    'image_1920': image1920,
  };

  /// Название отдела
  String get departmentName =>
      departmentId.length > 1 ? departmentId[1].toString() : '';

  /// Название должности
  String get jobTitle => jobId.length > 1 ? jobId[1].toString() : '';

  /// 🔥 Получаем байты изображения из Base64
  Uint8List? get imageBytes {
    if (image1920 == null || image1920!.isEmpty) return null;

    try {
      // иногда Odoo возвращает base64 с переносами строк
      final cleaned = image1920!.replaceAll(RegExp(r'\s+'), '');
      return base64Decode(cleaned);
    } catch (e) {
      print('Ошибка при декодировании изображения: $e');
      return null;
    }
  }

  /// 💡 Альтернатива — data URI (если хочешь через Image.network)
  String? get imageUri {
    if (image1920 == null || image1920!.isEmpty) return null;
    return 'data:image/jpeg;base64,$image1920';
  }
}
