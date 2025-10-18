import 'package:flutter/material.dart';

class ShiftScheduleScreen extends StatefulWidget {
  const ShiftScheduleScreen({super.key});

  @override
  State<ShiftScheduleScreen> createState() => _ShiftScheduleScreenState();
}

class _ShiftScheduleScreenState extends State<ShiftScheduleScreen> {
  DateTime selectedMonth = DateTime(2024, 10);
  DateTime? selectedDate = DateTime(2024, 10, 1);
  bool showVersionWarning = false;

  // Weekend dates (Saturdays) for highlighting
  final List<int> weekendDates = [5, 12, 19, 26];

  void _previousMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  void _selectDate(int day) {
    setState(() {
      selectedDate = DateTime(selectedMonth.year, selectedMonth.month, day);
    });
  }

  String _getMonthYear() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[selectedMonth.month - 1]} ${selectedMonth.year}';
  }

  List<int?> _getCalendarDays() {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7; // Convert to 0 = Sunday

    List<int?> days = List.filled(startWeekday, null, growable: true);
    days.addAll(List.generate(daysInMonth, (index) => index + 1));

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'График смен',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Calendar Widget
                  _buildCalendar(),

                  const SizedBox(height: 16),

                  // Workday Card
                  _buildShiftCard(
                    icon: Icons.work_outline,
                    title: 'Рабочий день',
                    subtitle: '8:00 AM - 5:00 PM',
                    iconColor: const Color(0xFF3F3D56),
                  ),

                  const SizedBox(height: 12),

                  // Off Day Card
                  _buildShiftCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Выходной день',
                    subtitle: 'Весь день',
                    iconColor: const Color(0xFF3F3D56),
                  ),

                  const SizedBox(height: 16),

                  // // Warning Banner
                  // if (showVersionWarning) _buildWarningBanner(),

                  // const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Acknowledge Button
          _buildAcknowledgeButton(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Text(
                _getMonthYear(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekday Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),

          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = _getCalendarDays();

    return Column(
      children: List.generate((days.length / 7).ceil(), (weekIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final index = weekIndex * 7 + dayIndex;
              if (index >= days.length) return const SizedBox(width: 40);

              final day = days[index];
              if (day == null) return const SizedBox(width: 40);

              final isSelected = selectedDate?.day == day;
              final isWeekend = weekendDates.contains(day);

              return _buildCalendarDay(day, isSelected, isWeekend);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarDay(int day, bool isSelected, bool isWeekend) {
    return GestureDetector(
      onTap: () => _selectDate(day),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isWeekend
              ? const Color(0xFFE8E8F0)
              : (isSelected ? Colors.white : Colors.transparent),
          border: isSelected
              ? Border.all(color: const Color(0xFF3F3D56), width: 2)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE5A3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 24,
          ),
          const SizedBox(width: 12),
          // Expanded(
          //   child: RichText(
          //     text: const TextSpan(
          //       style: TextStyle(fontSize: 14, color: Color(0xFF78350F)),
          //       children: [
          //         TextSpan(
          //           text: 'Новая версия доступна, ',
          //           style: TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //         TextSpan(text: 'Пожалуйста подтвердите.'),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAcknowledgeButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Handle acknowledge action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('График подтвержден!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F3D56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Подтвердить',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
