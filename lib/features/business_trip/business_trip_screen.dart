import 'package:flutter/material.dart';

class BusinessTripScreen extends StatefulWidget {
  const BusinessTripScreen({Key? key}) : super(key: key);

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
  String _selectedTransport = 'Plane';

  final List<String> _transportTypes = [
    'Plane',
    'Train',
    'Bus',
    'Car',
    'Other',
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
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business trip submitted successfully')),
      );
    }
  }

  void _signBusinessTrip() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening signature page...')));
  }

  void _uploadExpenseReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening file picker...')));
  }

  void _signWithFaceId() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Face ID authentication initiated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Business Trip',
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

                // Destination Field
                _buildLabel('Destination'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _destinationController,
                  hint: 'e.g., Berlin',
                ),

                const SizedBox(height: 20),

                // Purpose Field
                _buildLabel('Purpose'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _purposeController,
                  hint: 'e.g., Client Meeting',
                ),

                const SizedBox(height: 20),

                // Date Fields Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Date'),
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
                          _buildLabel('End Date'),
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

                // Transport Type Dropdown
                _buildLabel('Transport Type'),
                const SizedBox(height: 8),
                _buildDropdown(),

                const SizedBox(height: 20),

                // Estimated Budget Field
                _buildLabel('Estimated Budget'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _budgetController,
                  hint: 'e.g., 500 EUR',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                // Submit Button
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
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Sign Business Trip Order Button
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
                      'Sign Business Trip Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F3D56),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Upload Expense Report Button
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
                      'Upload Expense Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F3D56),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Trip Report Preview
                _buildLabel('Trip Report Preview'),
                const SizedBox(height: 12),
                _buildReportPreview(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
                color: displayText == 'mm/dd/yyyy'
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
                  'Report for',
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
            onPressed: _signWithFaceId,
            icon: const Icon(Icons.fingerprint, size: 20),
            label: const Text(
              'Sign with Face\nID',
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

  Widget _buildBottomNavigationBar() {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.person_outline, 'Profile', false),
              _buildNavItem(Icons.description_outlined, 'Documents', false),
              _buildNavItem(Icons.calendar_today_outlined, 'Leave', false),
              _buildNavItem(Icons.flight, 'Trips', true),
              _buildNavItem(Icons.favorite_outline, 'Sick Leave', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF3F3D56) : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF3F3D56) : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
