import 'dart:convert';
import 'package:hrgo_app/common/constants.dart';
import 'package:hrgo_app/core/secure_storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String baseUrl = 'http://api-dev.hrgo.kz';
  final SecureStorageService secureStorageService = SecureStorageService();

  /// Получение профиля сотрудника по ID
  Future<ProfileModel> getEmployeeProfile() async {
    try {
      final employeeId = await secureStorageService.readData(
        Constants.employeeIdStorageKey,
      );
      if (employeeId == null || employeeId.isEmpty) {
        throw Exception('Employee ID not found.');
      }

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
  final DepartmentModel? department;
  final JobModel? job;
  final String? imageUrl;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.department,
    this.job,
    this.imageUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department_id'] is Map<String, dynamic>
          ? DepartmentModel.fromJson(json['department_id'])
          : null,
      job: json['job_id'] is Map<String, dynamic>
          ? JobModel.fromJson(json['job_id'])
          : null,
      imageUrl: json['image_1920']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'department_id': department?.toJson(),
    'job_id': job?.toJson(),
    'image_1920': imageUrl,
  };

  /// Название отдела
  String get departmentName => department?.name ?? '';

  /// Название должности
  String get jobTitle => job?.name ?? '';

  /// ✅ Возвращает ссылку для Image.network()
  String? get imageNetworkUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    return 'http://api-dev.hrgo.kz$imageUrl';
  }
}

/// Модель отдела
class DepartmentModel {
  final int id;
  final String name;
  final String? model;

  DepartmentModel({required this.id, required this.name, this.model});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      model: json['model']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'model': model};
}

/// Модель должности
class JobModel {
  final int id;
  final String name;
  final String? model;

  JobModel({required this.id, required this.name, this.model});

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      model: json['model']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'model': model};
}
