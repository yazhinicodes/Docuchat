import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() => runApp(const DocuChatApp());

class DocuChatApp extends StatelessWidget {
  const DocuChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocuChat',
      debugShowCheckedModeBanner: false, // removes the red DEBUG ribbon
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF3F4F8),
      ),
      home: const ChatScreen(),
    );
  }
}