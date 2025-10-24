import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';
import 'package:hrgo_app/features/login/login_screen.dart';
import 'package:hrgo_app/features/profile/domain/profile_service.dart';
import 'package:hrgo_app/features/hr_document/hr_document_screen.dart';
import 'package:hrgo_app/features/leave/leave_screen.dart';
import 'package:hrgo_app/features/business_trip/business_trip_screen.dart';
import 'package:hrgo_app/features/sick_leave/sick_leave_screen.dart';
import 'package:hrgo_app/features/shift_schedule/shift_schedule_screen.dart';
import 'package:hrgo_app/features/termination/termination_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileService _profileService;
  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getEmployeeProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'HRGo',
          style: TextStyle(
            color: Color(0xFF2C3E7C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF2C3E7C),
              size: 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.bot,
              color: Color(0xFF2C3E7C),
              size: 28,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiChatScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildLoading() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E7C)),
        ),
        SizedBox(height: 16),
        Text(
          'Загрузка профиля...',
          style: TextStyle(color: Color(0xFF2C3E7C), fontSize: 16),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки',
            style: TextStyle(
              color: Color(0xFF2C3E7C),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Произошла неизвестная ошибка',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8B92B0), fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E7C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildContent() {
    final profile = _profile;
    if (profile == null) return _buildError();

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: const Color(0xFF2C3E7C),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatar(profile.imageNetworkUrl),
            const SizedBox(height: 24),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2C3E7C),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.jobTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8B92B0),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.departmentName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B92B0), fontSize: 16),
            ),
            const SizedBox(height: 40),
            ..._buildMenuItems(profile),
            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageUri) {
    if (imageUri == null || imageUri.isEmpty) {
      return _defaultAvatar();
    }

    final fullUrl = imageUri;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2C3E7C), width: 4),
        color: const Color(0xFFE8D5C4),
      ),
      child: ClipOval(
        child: Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Ошибка загрузки фото: $error');
            return _defaultAvatar();
          },
        ),
      ),
    );
  }

  Widget _defaultAvatar() =>
      const Icon(Icons.person, size: 100, color: Color(0xFF2C3E7C));

  List<Widget> _buildMenuItems(ProfileModel profile) {
    final items = [
      (
        'Кадровые документы',
        HRDocumentsScreen(
          employeeName: profile.name,
          employeeId: profile.id,
          position: profile.jobTitle,
          hireDate: profile.email,
          avatarPath: profile.imageUrl,
        ),
      ),
      ('Отпуск', const LeaveScreen()),
      ('Командировки', const BusinessTripScreen()),
      ('Больничный лист', const SickLeaveScreen()),
      ('График смен', const ShiftScheduleScreen()),
      ('Прекращение', const TerminationScreen()),
    ];

    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.$2),
              ),
              child: _buildMenuItem(item.$1),
            ),
          ),
        )
        .toList();
  }

  Widget _buildMenuItem(String title) => Container(
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2C3E7C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Icon(Icons.chevron_right, color: Color(0xFF2C3E7C), size: 28),
      ],
    ),
  );

  Widget _buildLogoutButton() => Container(
    width: double.infinity,
    height: 60,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2C3E7C), width: 2),
    ),
    child: TextButton(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
      child: const Text(
        'Выйти',
        style: TextStyle(
          color: Color(0xFF2C3E7C),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
