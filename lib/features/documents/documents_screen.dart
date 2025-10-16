import 'package:flutter/material.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<DocumentItem> documents = [
    DocumentItem(title: 'Трудовой договор'),
    DocumentItem(title: 'Приказ о приеме на работу'),
    DocumentItem(title: 'Соглашение о защите данных и конфиденциальности'),
    DocumentItem(title: 'Дополнительное соглашение'),
  ];

  void _onDocumentTap(int index) {
    print('Document tapped: ${documents[index].title}');
    // Add navigation or action here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Color(0xFF3D3D7E)),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
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
      body: Padding(
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
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                title: Text(
                  documents[index].title,
                  style: const TextStyle(
                    color: Color(0xFF3D3D7E),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF3D3D7E),
                  size: 20,
                ),
                onTap: () => _onDocumentTap(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DocumentItem {
  final String title;

  DocumentItem({required this.title});
}
