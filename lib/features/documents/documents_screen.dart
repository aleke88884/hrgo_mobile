import 'package:flutter/material.dart';
import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';
import 'package:hrgo_app/features/document_viewer/document_viewer_screen.dart';
import 'package:hrgo_app/features/document_viewer/domain/document_service.dart';

import 'package:hrgo_app/features/documents/employee_documents_service.dart';
import 'package:hrgo_app/features/sign_verigram/document_signing_webview.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Экран со списком документов сотрудника (без проверки)
class DocumentsScreen extends StatefulWidget {
  final int?
  employeeId; // Опциональный ID, если null - используется текущий пользователь

  const DocumentsScreen({super.key, this.employeeId});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final EmployeeDocumentsService _employeeDocumentsService =
      EmployeeDocumentsService();
  final DocumentService _documentService = DocumentService();

  bool _isLoadingList = true;
  bool _isLoadingDocument = false;
  List<DocumentItem> _documents = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  /// Загрузка списка документов сотрудника
  Future<void> _loadDocuments() async {
    setState(() {
      _isLoadingList = true;
      _errorMessage = null;
    });

    try {
      final response = await _employeeDocumentsService.getEmployeeDocuments();

      setState(() {
        _documents = response.getAllDocuments();
        _isLoadingList = false;
      });

      print('✅ Загружено документов: ${_documents.length}');
    } on DocumentsException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoadingList = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Неизвестная ошибка: $e';
        _isLoadingList = false;
      });
    }
  }

  /// Открыть документ для просмотра
  Future<void> _onDocumentTap(DocumentItem document) async {
    setState(() => _isLoadingDocument = true);

    try {
      final filePath = await _documentService.getDocument(
        modelName: document.model,
        documentId: document.id,
      );

      setState(() => _isLoadingDocument = false);

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DocumentViewerScreen(filePath: filePath, title: document.title),
          ),
        );
      }
    } on DocumentException catch (e) {
      setState(() => _isLoadingDocument = false);
      if (mounted) {
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      setState(() => _isLoadingDocument = false);
      if (mounted) {
        _showErrorSnackbar('Ошибка открытия документа: $e');
      }
    }
  }

  Future<void> _onSignDocument(DocumentItem document) async {
    setState(() => _isLoadingDocument = true);

    try {
      final vlink = await _documentService.signDocument(
        documentModel: document.model,
        documentId: '${document.id}',
      );

      setState(() => _isLoadingDocument = false);

      if (mounted) {
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentSigningWebView(url: vlink),
          ),
        );

        if (success == true) {
          _showSnackbar('Документ успешно подписан!');
          await _loadDocuments(); // обновим список
        } else {
          _showSnackbar('Подписание отменено или не завершено.');
        }
      }
    } on DocumentException catch (e) {
      _showErrorSnackbar(e.message);
    } catch (e) {
      _showErrorSnackbar('Ошибка при подписании: $e');
    } finally {
      setState(() => _isLoadingDocument = false);
    }
  }

  void _showSnackbar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
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
          'Документы',
          style: TextStyle(
            color: Color(0xFF3D3D7E),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2C3E7C)),
            onPressed: _isLoadingList ? null : _loadDocuments,
            tooltip: 'Обновить',
          ),
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
      body: Stack(
        children: [
          _buildContent(),
          if (_isLoadingDocument) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingList) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Загрузка документов...',
              style: TextStyle(fontSize: 16, color: Color(0xFF3D3D7E)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF3D3D7E)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDocuments,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить попытку'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E7C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 64,
                color: Color(0xFFB0B0B0),
              ),
              const SizedBox(height: 16),
              const Text(
                'Нет доступных документов',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3D3D7E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Документы появятся здесь после их создания',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _loadDocuments,
                icon: const Icon(Icons.refresh),
                label: const Text('Обновить'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2C3E7C),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: _documents.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5E5EA),
            indent: 68,
          ),
          itemBuilder: (context, index) {
            final document = _documents[index];
            return _buildDocumentTile(document);
          },
        ),
      ),
    );
  }

  Widget _buildDocumentTile(DocumentItem document) {
    final bool canSign = document.state == 'under_approval_employee';
    final bool isApproved = document.state == 'approved';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getDocumentColor(document.model).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    document.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(
                document.title,
                style: const TextStyle(
                  color: Color(0xFF3D3D7E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (document.state != null)
                      _buildStatusChip(document.state!),
                  ],
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF3D3D7E),
                size: 16,
              ),
              onTap: () => _onDocumentTap(document),
            ),

            // Разделитель между информацией и действиями
            const Divider(height: 16, thickness: 1, color: Color(0xFFE5E5EA)),

            // Действия под документом (с кнопкой или статусом)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canSign)
                  ElevatedButton.icon(
                    onPressed: _isLoadingDocument
                        ? null
                        : () async => await _onSignDocument(document),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.edit_document, size: 18),
                    label: const Text(
                      'Подписать',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                else if (isApproved)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Документ утверждён',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 36), // чтобы выровнять высоту карточек
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String state) {
    Color color;
    IconData icon;

    switch (state) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'under_approval_employee':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'draft':
        color = Colors.grey;
        icon = Icons.edit_note;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            DocumentItem.getStateText(state),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDocumentColor(String model) {
    if (model.contains('contract')) return Colors.blue;
    if (model.contains('leave')) return Colors.green;
    return const Color(0xFF2C3E7C);
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Загрузка документа...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
