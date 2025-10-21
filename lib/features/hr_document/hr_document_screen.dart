import 'package:flutter/material.dart';
import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';
import 'package:hrgo_app/features/document_viewer/document_viewer_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HRDocumentsScreen extends StatefulWidget {
  const HRDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<HRDocumentsScreen> createState() => _HRDocumentsScreenState();
}

class _HRDocumentsScreenState extends State<HRDocumentsScreen> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Кадровые документы (проверка)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Employee Info Card
                  Container(
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
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset('assets/profile.jpg'),

                          // const Icon(
                          //   Icons.person_outline,
                          //   size: 40,
                          //   color: Color(0xFF9E9E9E),
                          // ),
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aidar Nurlibek',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Инженер отдела технического обслуживания',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Июнь 10, 2024',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions Text
                  const Text(
                    'Пожалуйста, внимательно ознакомьтесь с представленными ниже кадровыми документами. После прочтения отметьте, что вы ознакомились со всеми документами, и нажмите кнопку "Proceed to Signing", чтобы продолжить процесс подписания.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF424242),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Document List
                  _buildDocumentItem('Трудовой договор.pdf'),
                  const SizedBox(height: 12),
                  _buildDocumentItem('Приказ о приеме на работу.pdf'),
                  const SizedBox(height: 12),
                  _buildDocumentItem('Защита данных и конфиденциальности.pdf'),
                  const SizedBox(height: 12),
                  _buildDocumentItem('Дополнительное соглашение.pdf'),
                  const SizedBox(height: 24),

                  // Checkbox
                  Container(
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
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isAgreed,
                            onChanged: (value) {
                              setState(() {
                                isAgreed = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Я ознакомился со всеми кадровыми документами и согласен с их содержанием.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF424242),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                  onPressed: isAgreed
                      ? () {
                          // Handle proceed to signing
                          print('Proceeding to signing...');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Перейти к подписанию',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF212121)),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to document viewer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentViewerScreen(filePath: ''),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Просмотреть',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3F51B5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDocumentContent(String title) {
    // Return different content based on document title
    return '';
  }
}
