import 'package:flutter/material.dart';

class BusinessTripScreen extends StatefulWidget {
  const BusinessTripScreen({super.key});

  @override
  State<BusinessTripScreen> createState() => _BusinessTripScreenState();
}

class _BusinessTripScreenState extends State<BusinessTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedTransport = 'Самолет';

  final List<String> _transportTypes = [
    'Самолет',
    'Поезд',
    'Автобус',
    'Автомобиль',
    'Другое',
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    _purposeController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3F3D56),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'дд/мм/гггг';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Командировка успешно отправлена')),
      );
    }
  }

  void _signBusinessTrip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Открывается страница подписи...')),
    );
  }

  void _uploadExpenseReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Открывается выбор файла...')));
  }

  void _signWithFaceId() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Инициализация Face ID...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Командировка',
          style: TextStyle(
            color: Color(0xFF3F3D56),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Пункт назначения
                _buildLabel('Пункт назначения'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _destinationController,
                  hint: 'например, Берлин',
                ),

                const SizedBox(height: 20),

                // Цель поездки
                _buildLabel('Цель поездки'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _purposeController,
                  hint: 'например, Встреча с клиентом',
                ),

                const SizedBox(height: 20),

                // Даты поездки
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Дата начала'),
                          const SizedBox(height: 8),
                          _buildDateField(
                            _formatDate(_startDate),
                            () => _selectDate(context, true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Дата окончания'),
                          const SizedBox(height: 8),
                          _buildDateField(
                            _formatDate(_endDate),
                            () => _selectDate(context, false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Транспорт
                _buildLabel('Вид транспорта'),
                const SizedBox(height: 8),
                _buildDropdown(),

                const SizedBox(height: 20),

                // Бюджет
                _buildLabel('Ориентировочный бюджет'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _budgetController,
                  hint: 'например, 500 EUR',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                // Отправить
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
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
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Подписать приказ
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _signBusinessTrip,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3F3D56)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFFF0F0F5),
                    ),
                    child: const Text(
                      'Подписать приказ о командировке',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F3D56),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Загрузить отчет
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _uploadExpenseReport,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3F3D56)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: const Color(0xFFF0F0F5),
                    ),
                    child: const Text(
                      'Загрузить отчет о расходах',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F3D56),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Превью отчета
                _buildLabel('Предпросмотр отчета'),
                const SizedBox(height: 12),
                _buildReportPreview(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF3F3D56),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateField(String displayText, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText,
              style: TextStyle(
                fontSize: 16,
                color: displayText == 'дд/мм/гггг'
                    ? Colors.grey.shade400
                    : Colors.black,
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTransport,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          style: const TextStyle(fontSize: 16, color: Colors.black),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTransport = newValue;
              });
            }
          },
          items: _transportTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Отчет по',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Berlin_Meeting.pdf',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F3D56),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: null, // <-- изменим ниже
            icon: const Icon(Icons.fingerprint, size: 20),
            label: const Text(
              'Подписать\nFace ID',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0F0F5),
              foregroundColor: const Color(0xFF3F3D56),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
