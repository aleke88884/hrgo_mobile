import 'package:flutter/material.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  String _language = 'Русский';
  String _style = 'Дружелюбный';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки бота')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'Русский', child: Text('Русский')),
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Қазақша', child: Text('Қазақша')),
              ],
              decoration: const InputDecoration(labelText: 'Язык'),
              onChanged: (v) => setState(() => _language = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _style,
              items: const [
                DropdownMenuItem(
                  value: 'Дружелюбный',
                  child: Text('Дружелюбный'),
                ),
                DropdownMenuItem(
                  value: 'Формальный',
                  child: Text('Формальный'),
                ),
                DropdownMenuItem(
                  value: 'Короткие ответы',
                  child: Text('Короткие ответы'),
                ),
              ],
              decoration: const InputDecoration(labelText: 'Стиль ответов'),
              onChanged: (v) => setState(() => _style = v!),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Очистить историю чата'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('История чата очищена')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
