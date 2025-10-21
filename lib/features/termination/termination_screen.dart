import 'package:flutter/material.dart';
import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TerminationScreen extends StatefulWidget {
  const TerminationScreen({Key? key}) : super(key: key);

  @override
  State<TerminationScreen> createState() => _TerminationScreenState();
}

class _TerminationScreenState extends State<TerminationScreen> {
  bool isEmployeeSignatureCompleted = true;
  bool isProcessCompleted = true;

  Future<void> _handleFaceIdSignature() async {
    // Здесь реализуется логика подписи через Face ID
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Инициализация подписи через Face ID')),
    );
  }

  Future<void> _openDocument(String fileName) async {
    // Здесь реализуется логика открытия документа
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Открытие документа: $fileName')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Увольнение',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.bot,
              color: Color(0xFF2C3E7C),
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Раздел: Приказ об увольнении
              const Text(
                'Приказ об увольнении (PDF)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDocumentCard(
                'Приказ_об_увольнении_Иванов.pdf',
                onTap: () => _openDocument('Приказ_об_увольнении_Иванов.pdf'),
              ),

              const SizedBox(height: 32),

              // Раздел: Обходной лист
              const Text(
                'Обходной лист (PDF)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDocumentCard(
                'Обходной_лист_Иванов.pdf',
                onTap: () => _openDocument('Обходной_лист_Иванов.pdf'),
              ),

              const SizedBox(height: 32),

              // Кнопка: Подписать через Face ID
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleFaceIdSignature,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F3D56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.fingerprint, size: 24, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Подписать через Face ID',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Статус процесса
              Center(
                child: Column(
                  children: [
                    Text(
                      'Подпись сотрудника завершена',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isEmployeeSignatureCompleted
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Подпись работодателя доступна в ERP Web Client',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Процесс завершён',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isProcessCompleted ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDocumentCard(String fileName, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                fileName,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Icon(
              Icons.file_download_outlined,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ],
        ),
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
              _buildNavItem(Icons.person_outline, 'Профиль', false),
              _buildNavItem(Icons.description_outlined, 'Документы', true),
              _buildNavItem(Icons.calendar_today_outlined, 'Отпуск', false),
              _buildNavItem(Icons.location_on_outlined, 'Командировки', false),
              _buildNavItem(Icons.access_time, 'Больничный', false),
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
