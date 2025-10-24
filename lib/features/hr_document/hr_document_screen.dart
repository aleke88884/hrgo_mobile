import 'package:flutter/material.dart';
import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';
import 'package:hrgo_app/features/document_viewer/document_viewer_screen.dart';
import 'package:hrgo_app/features/document_viewer/domain/document_service.dart';
import 'package:hrgo_app/features/documents/employee_documents_service.dart';
import 'package:hrgo_app/features/sign_verigram/document_signing_webview.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HRDocumentsScreen extends StatefulWidget {
  final int? employeeId;
  final String employeeName;
  final String position;
  final String hireDate;
  final String? avatarPath;

  const HRDocumentsScreen({
    super.key,
    this.employeeId,
    this.employeeName = 'Aidar Nurlibek',
    this.position = 'Инженер отдела технического обслуживания',
    this.hireDate = 'Июнь 10, 2024',
    this.avatarPath,
  });

  @override
  State<HRDocumentsScreen> createState() => _HRDocumentsScreenState();
}

class _HRDocumentsScreenState extends State<HRDocumentsScreen> {
  final EmployeeDocumentsService _employeeDocumentsService =
      EmployeeDocumentsService();
  final DocumentService _documentService = DocumentService();

  bool _isLoadingList = true;
  bool _isLoadingDocument = false;
  bool _isSigning = false;
  String? _errorMessage;

  List<DocumentItem> _documents = [];
  final Set<int> _signedDocuments = {};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

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
        _errorMessage = 'Ошибка загрузки документов: $e';
        _isLoadingList = false;
      });
    }
  }

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
      _showErrorSnackbar(e.message);
    } catch (e) {
      setState(() => _isLoadingDocument = false);
      _showErrorSnackbar('Ошибка открытия документа: $e');
    }
  }

  Future<void> _signDocument(DocumentItem document) async {
    setState(() => _isSigning = true);

    try {
      final vlink = await _documentService.signDocument(
        documentModel: document.model,
        documentId: '${document.id}',
      );

      print('✅ Документ ${document.title}. Ссылка: $vlink');

      setState(() => _isSigning = false);

      if (mounted) {
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentSigningWebView(url: vlink),
          ),
        );

        if (success == true) {
          setState(() {
            _signedDocuments.add(document.id);
          });
          await _loadDocuments();
          _showSnackbar('Документ успешно подписан!');
        } else {
          _showSnackbar('Подписание отменено или не завершено.');
        }
      }
    } on DocumentException catch (e) {
      _showErrorSnackbar(e.message);
    } catch (e) {
      _showErrorSnackbar('Ошибка при подписании: $e');
    } finally {
      setState(() => _isSigning = false);
    }
  }

  void _showSnackbar(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) =>
      _showSnackbar(message, error: true);

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
          'Кадровые документы',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bot, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoadingList)
            _buildLoadingState()
          else if (_errorMessage != null)
            _buildErrorState()
          else
            _buildContent(),
          if (_isLoadingDocument || _isSigning) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Загрузка документов...',
          style: TextStyle(fontSize: 16, color: Color(0xFF424242)),
        ),
      ],
    ),
  );

  Widget _buildErrorState() => Center(
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
            style: const TextStyle(fontSize: 16, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDocuments,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить попытку'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEmployeeInfoCard(),
          const SizedBox(height: 24),
          const Text(
            'Просмотрите и подпишите нужные документы. '
            'Подписанные документы отмечены галочкой.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 24),
          ..._documents.map(_buildDocumentItem),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfoCard() => Container(
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
        CircleAvatar(
          radius: 35,
          backgroundImage: widget.avatarPath != null
              ? NetworkImage(widget.avatarPath!)
              : null,
          backgroundColor: const Color(0xFFE0E0E0),
          child: widget.avatarPath == null
              ? const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: Color(0xFF9E9E9E),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.employeeName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              Text(widget.position, style: const TextStyle(color: Colors.grey)),
              Text(widget.hireDate, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildDocumentItem(DocumentItem doc) {
    final signed = _signedDocuments.contains(doc.id);
    final isApproved =
        (doc.state?.toLowerCase() == 'approved'); // ✅ проверяем статус

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: signed || isApproved
            ? Colors.green.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: signed || isApproved ? Colors.green : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            doc.title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF212121),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            doc.name,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 12),
          if (signed || isApproved)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.verified, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Документ утверждён',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onDocumentTap(doc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
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
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isApproved
                        ? null // ❌ нельзя нажать
                        : () => _signDocument(doc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApproved
                          ? Colors
                                .grey // 🔒 заблокированная кнопка
                          : Colors.lightGreen.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isApproved ? 'Утверждено' : 'Подписать',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() => Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _isSigning
                    ? 'Подписание документа...'
                    : 'Загрузка документа...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
