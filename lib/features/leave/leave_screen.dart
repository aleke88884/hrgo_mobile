import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _leaveType = 'Ежегодный';
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3F3D56),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF3F3D56),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        _startDateController.text = DateFormat('dd.MM.yyyy').format(date);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3F3D56),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF3F3D56),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _endDate = date;
        _endDateController.text = DateFormat('dd.MM.yyyy').format(date);
      });
    }
  }

  void _submitLeaveRequest() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите даты отпуска'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дата окончания не может быть раньше начальной даты'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заявка на отпуск успешно отправлена'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Просьба об отпуске',
          style: TextStyle(
            color: Color(0xFF3F3D56),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF3F3D56)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateField(
                label: 'Начальная дата',
                controller: _startDateController,
                onTap: _selectStartDate,
                selectedDate: _startDate,
              ),
              const SizedBox(height: 20),
              _buildDateField(
                label: 'Дата окончания',
                controller: _endDateController,
                onTap: _selectEndDate,
                selectedDate: _endDate,
              ),
              const SizedBox(height: 20),
              _buildLeaveTypeField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 32),
              const Text(
                'График отпусков',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3D56),
                ),
              ),
              const SizedBox(height: 16),
              _buildLeaveCard(
                dates: '22.04.2024 - 26.04.2024',
                status: 'pending',
              ),
              const SizedBox(height: 12),
              _buildLeaveCard(
                dates: '01.06.2024 - 15.06.2024',
                status: 'approved',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    required DateTime? selectedDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3F3D56),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedDate != null
                    ? const Color(0xFF3F3D56)
                    : Colors.grey.shade300,
                width: selectedDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: selectedDate != null
                      ? const Color(0xFF3F3D56)
                      : Colors.grey.shade500,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('dd.MM.yyyy').format(selectedDate)
                        : 'Выберите дату',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null
                          ? const Color(0xFF3F3D56)
                          : Colors.grey.shade500,
                      fontWeight: selectedDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тип отпуска',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3F3D56),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _leaveType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3F3D56)),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF3F3D56),
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            items: ['Ежегодный', 'Больничный', 'Без содержания', 'Учебный'].map(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              },
            ).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _leaveType = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitLeaveRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3F3D56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Отправить',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard({required String dates, required String status}) {
    final bool isApproved = status == 'approved';
    final bool isPending = status == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApproved
              ? Colors.green.shade300
              : isPending
              ? Colors.orange.shade300
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: const Color(0xFF3F3D56), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dates,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F3D56),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isApproved
                  ? Colors.green.shade50
                  : isPending
                  ? Colors.orange.shade50
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isApproved
                      ? Icons.check_circle
                      : isPending
                      ? Icons.schedule
                      : Icons.info,
                  size: 18,
                  color: isApproved
                      ? Colors.green.shade700
                      : isPending
                      ? Colors.orange.shade700
                      : Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  isApproved
                      ? 'Отпуск одобрен'
                      : isPending
                      ? 'На рассмотрении'
                      : 'Отклонен',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isApproved
                        ? Colors.green.shade700
                        : isPending
                        ? Colors.orange.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
