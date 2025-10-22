import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hrgo_app/features/chat_screen/ai_chat_screen.dart';

/// Экран просмотра PDF-документа с использованием pdfx
class DocumentViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.filePath,
    this.title = 'Документ',
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  PdfControllerPinch? _pdfController;
  int currentPage = 1;
  int totalPages = 0;
  bool isLoading = true;
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
      body: Builder(
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
                backgroundDecoration: const BoxDecoration(color: Colors.white),
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
                  bottom: 16,
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
