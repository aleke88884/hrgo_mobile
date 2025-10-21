import 'package:flutter/material.dart';
import 'package:hrgo_app/features/business_trip/business_trip_screen.dart';
import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';
import 'package:hrgo_app/features/hr_document/hr_document_screen.dart';
import 'package:hrgo_app/features/leave/leave_screen.dart';
import 'package:hrgo_app/features/login/login_screen.dart';
import 'package:hrgo_app/features/shift_schedule/shift_schedule_screen.dart';
import 'package:hrgo_app/features/termination/termination_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
            icon: const Icon(Icons.chat, color: Color(0xFF2C3E7C), size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Avatar
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2C3E7C), width: 4),
                  color: const Color(0xFFE8D5C4),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/profile.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 100,
                        color: Color(0xFF2C3E7C),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Name
              const Text(
                'Aidar Nurlibek',
                style: TextStyle(
                  color: Color(0xFF2C3E7C),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Job Title
              const Text(
                'Менеджер по персоналу',
                style: TextStyle(
                  color: Color(0xFF8B92B0),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              // Menu Items
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return HRDocumentsScreen();
                      },
                    ),
                  );
                },
                child: _buildMenuItem(context, 'Документы'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return LeaveScreen();
                      },
                    ),
                  );
                },
                child: _buildMenuItem(context, 'Отпуск'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return BusinessTripScreen();
                      },
                    ),
                  );
                },
                child: _buildMenuItem(context, 'Командировки'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return LeaveScreen();
                      },
                    ),
                  );
                },
                child: _buildMenuItem(context, 'Отпуск больничный'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return ShiftScheduleScreen();
                    },
                  ),
                ),
                child: _buildMenuItem(context, 'График смен'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return TerminationScreen();
                      },
                    ),
                  );
                },
                child: _buildMenuItem(context, 'Прекращение'),
              ),
              const SizedBox(height: 40),
              // Logout Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C3E7C), width: 2),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Выйти',
                    style: TextStyle(
                      color: Color(0xFF2C3E7C),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title) {
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: Padding(
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
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF2C3E7C),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
