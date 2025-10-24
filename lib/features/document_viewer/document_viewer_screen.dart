import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';
import 'package:hrgo_app/features/document_viewer/domain/document_service.dart';
import 'package:hrgo_app/features/sign_verigram/document_signing_webview.dart';

/// Экран просмотра PDF-документа с использованием pdfx
class DocumentViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final String? documentId;
  final String? documentModel;
  final String? documentState;
  final bool canSign;

  const DocumentViewerScreen({
    super.key,
    required this.filePath,
    this.title = 'Документ',
    this.documentId,
    this.documentModel,
    this.documentState,
    this.canSign = false,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  final DocumentService _documentService = DocumentService();

  PdfControllerPinch? _pdfController;
  int currentPage = 1;
  int totalPages = 0;
  bool isLoading = true;
  bool isSigningInProgress = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      final file = File(widget.filePath);
      print('🔍 Проверяем файл: ${widget.filePath}');
      if (!(await file.exists())) {
        print('❌ Файл не существует по пути: ${widget.filePath}');
        setState(() {
          errorMessage = 'Файл не найден по пути:\n${widget.filePath}';
          isLoading = false;
        });
        return;
      }

      print('✅ Файл существует, размер: ${await file.length()} байт');

      // Загружаем документ с тайм-аутом
      final document = await Future.any([
        PdfDocument.openFile(widget.filePath),
        Future.delayed(const Duration(seconds: 10), () {
          throw TimeoutException('Превышено время загрузки PDF');
        }),
      ]);

      print('📄 Документ загружен, страниц: ${document.pagesCount}');

      _pdfController = PdfControllerPinch(
        document: Future.value(document),
        initialPage: currentPage,
      );

      setState(() {
        totalPages = document.pagesCount;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ Ошибка в _initPdf: $e\n$stackTrace');
      setState(() {
        errorMessage = 'Ошибка открытия PDF: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _shareDocument() async {
    try {
      final file = File(widget.filePath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(widget.filePath)], text: widget.title);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Файл не найден')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при попытке поделиться: $e')),
        );
      }
    }
  }

  /// Подписать документ
  Future<void> _signDocument() async {
    if (widget.documentId == null || widget.documentModel == null) {
      _showErrorSnackbar('Не удалось определить документ для подписи');
      return;
    }

    // Показываем диалог подтверждения
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подписание документа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вы уверены, что хотите подписать этот документ?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Документ: ${widget.title}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.draw),
            label: const Text('Продолжить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E7C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isSigningInProgress = true);

    try {
      // Получаем ссылку для подписания
      final vlink = await _documentService.signDocument(
        documentId: widget.documentId!,
        documentModel: widget.documentModel!,
      );

      print('✅ Получена ссылка для подписания: $vlink');

      setState(() => isSigningInProgress = false);

      if (mounted) {
        // Переходим к экрану подписания через WebView
        final signingSuccessful = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentSigningWebView(url: vlink),
          ),
        );

        // Если подписание прошло успешно
        if (signingSuccessful == true) {
          if (mounted) {
            _showSuccessSnackbar('Документ успешно подписан!');
            // Возвращаемся на предыдущий экран с результатом true
            Navigator.pop(context, true);
          }
        } else {
          // Подписание отменено или не завершено
          _showErrorSnackbar('Подписание отменено или не завершено');
        }
      }
    } on DocumentException catch (e) {
      setState(() => isSigningInProgress = false);
      _showErrorSnackbar(e.message);
    } catch (e) {
      setState(() => isSigningInProgress = false);
      _showErrorSnackbar('Ошибка при подписании: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
            tooltip: 'Поделиться',
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.bot,
              color: Color(0xFF2C3E7C),
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
            tooltip: 'Открыть AI-чат',
          ),
        ],
      ),
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              if (errorMessage != null) {
                return _buildErrorWidget(theme);
              }

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_pdfController == null) {
                return _buildErrorWidget(theme);
              }

              return Stack(
                children: [
                  PdfViewPinch(
                    controller: _pdfController!,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    onDocumentError: (error) {
                      setState(() {
                        errorMessage = 'Ошибка документа: $error';
                        isLoading = false;
                      });
                    },
                    onPageChanged: (page) {
                      setState(() => currentPage = page);
                    },
                  ),
                  // Индикатор текущей страницы
                  if (totalPages > 0)
                    Positioned(
                      bottom: widget.canSign ? 90 : 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$currentPage / $totalPages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Оверлей загрузки при подписании
          if (isSigningInProgress) _buildSigningOverlay(),
        ],
      ),
      // Кнопка подписи внизу экрана
      bottomNavigationBar: widget.canSign && !isLoading && errorMessage == null
          ? _buildSignButton()
          : null,
    );
  }

  Widget _buildSignButton() {
    return Container(
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
        child: ElevatedButton.icon(
          onPressed: isSigningInProgress ? null : _signDocument,
          icon: const Icon(Icons.draw, size: 20),
          label: const Text(
            'Подписать документ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C3E7C),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSigningOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Card(
          margin: EdgeInsets.all(32),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Подготовка к подписанию...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Пожалуйста, подождите',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки документа',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Неизвестная ошибка',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}
