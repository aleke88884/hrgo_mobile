import 'package:flutter/material.dart';
import 'package:hrgo_app/features/document_viewer/document_viewer_screen.dart';
import 'package:hrgo_app/features/document_viewer/domain/document_service.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentService _documentService = DocumentService();
  bool _isLoading = false;

  // Список документов с моделью и ID
  final List<DocumentItem> documents = [
    DocumentItem(
      title: 'Трудовой договор',
      modelName: 'hr.contract',
      documentId: 16, // Замените на реальный ID
    ),
    DocumentItem(
      title: 'Приказ о приеме на работу',
      modelName: 'hr.contract',
      documentId: 17, // Замените на реальный ID
    ),
    DocumentItem(
      title: 'Соглашение о защите данных и конфиденциальности',
      modelName: 'hr.contract',
      documentId: 18, // Замените на реальный ID
    ),
    DocumentItem(
      title: 'Дополнительное соглашение',
      modelName: 'hr.contract',
      documentId: 19, // Замените на реальный ID
    ),
  ];

  /// Открыть документ
  Future<void> _onDocumentTap(DocumentItem document) async {
    // Показываем индикатор загрузки
    setState(() => _isLoading = true);

    try {
      // Получаем PDF файл с сервера
      final filePath = await _documentService.getDocument(
        modelName: document.modelName,
        documentId: document.documentId,
      );

      // Скрываем индикатор загрузки
      setState(() => _isLoading = false);

      // Открываем просмотрщик PDF
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DocumentViewerScreen(filePath: filePath, title: document.title),
          ),
        );

        // После закрытия экрана удаляем временный файл
        await _documentService.deleteTemporaryFile(filePath);
      }
    } on DocumentException catch (e) {
      // Обработка ошибок от сервиса
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Обработка неожиданных ошибок
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Неизвестная ошибка: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: documents.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE5E5EA),
                ),
                itemBuilder: (context, index) {
                  final document = documents[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 32,
                    ),
                    title: Text(
                      document.title,
                      style: const TextStyle(
                        color: Color(0xFF3D3D7E),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'ID: ${document.documentId}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF3D3D7E),
                      size: 20,
                    ),
                    onTap: _isLoading ? null : () => _onDocumentTap(document),
                  );
                },
              ),
            ),
          ),

          // Индикатор загрузки поверх всего экрана
          if (_isLoading)
            Container(
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Модель документа с необходимыми данными для запроса
class DocumentItem {
  final String title;
  final String modelName;
  final int documentId;

  DocumentItem({
    required this.title,
    required this.modelName,
    required this.documentId,
  });
}

// ============================================
// АЛЬТЕРНАТИВНЫЙ ВАРИАНТ: Если документы приходят с сервера
// ============================================

class DocumentsScreenDynamic extends StatefulWidget {
  final int employeeId; // ID сотрудника для загрузки его документов

  const DocumentsScreenDynamic({super.key, required this.employeeId});

  @override
  State<DocumentsScreenDynamic> createState() => _DocumentsScreenDynamicState();
}

class _DocumentsScreenDynamicState extends State<DocumentsScreenDynamic> {
  final DocumentService _documentService = DocumentService();
  bool _isLoadingList = true;
  bool _isLoadingDocument = false;
  List<DocumentItem> documents = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  /// Загрузка списка документов (замените на ваш API метод)
  Future<void> _loadDocuments() async {
    setState(() {
      _isLoadingList = true;
      errorMessage = null;
    });

    try {
      // TODO: Замените на реальный API запрос для получения списка документов
      // Пример: final response = await _yourApiService.getEmployeeDocuments(widget.employeeId);

      // Имитация загрузки
      await Future.delayed(const Duration(seconds: 1));

      // Пример данных (замените на реальные из API)
      setState(() {
        documents = [
          DocumentItem(
            title: 'Трудовой договор',
            modelName: 'hr.contract',
            documentId: 16,
          ),
          DocumentItem(
            title: 'Приказ о приеме',
            modelName: 'hr.contract',
            documentId: 17,
          ),
        ];
        _isLoadingList = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка загрузки списка документов: $e';
        _isLoadingList = false;
      });
    }
  }

  Future<void> _onDocumentTap(DocumentItem document) async {
    setState(() => _isLoadingDocument = true);

    try {
      final filePath = await _documentService.getDocument(
        modelName: document.modelName,
        documentId: document.documentId,
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

        await _documentService.deleteTemporaryFile(filePath);
      }
    } on DocumentException catch (e) {
      setState(() => _isLoadingDocument = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoadingList)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDocuments,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            )
          else if (documents.isEmpty)
            const Center(child: Text('Нет доступных документов'))
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: documents.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE5E5EA),
                  ),
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 32,
                      ),
                      title: Text(
                        document.title,
                        style: const TextStyle(
                          color: Color(0xFF3D3D7E),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${document.documentId}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF3D3D7E),
                        size: 20,
                      ),
                      onTap: _isLoadingDocument
                          ? null
                          : () => _onDocumentTap(document),
                    );
                  },
                ),
              ),
            ),

          if (_isLoadingDocument)
            Container(
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
