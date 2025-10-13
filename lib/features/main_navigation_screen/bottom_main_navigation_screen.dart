import 'package:flutter/material.dart';
import 'package:hrgo_app/features/business_trip/business_trip_screen.dart';
import 'package:hrgo_app/features/documents/documents_screen.dart';
import 'package:hrgo_app/features/leave/leave_screen.dart';
import 'package:hrgo_app/features/profile/profile_screen.dart';

class BottomMainNavigationScreen extends StatefulWidget {
  const BottomMainNavigationScreen({super.key});

  @override
  State<BottomMainNavigationScreen> createState() =>
      _BottomMainNavigationScreenState();
}

class _BottomMainNavigationScreenState
    extends State<BottomMainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ProfileScreen(),
    DocumentsScreen(),
    LeaveScreen(),
    BusinessTripScreen(),
    LeaveScreen(),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3D3D7E),
          unselectedItemColor: const Color(0xFF9E9E9E),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              label: 'Documents',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Leave',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.share_outlined),
              label: 'Sick leave',
            ),
          ],
        ),
      ),
    );
  }
}
