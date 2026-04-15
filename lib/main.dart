import 'package:flutter/material.dart';
import 'screens/chat/chat_screen.dart';

void main() {
  runApp(const PingApp());
}

class PingApp extends StatelessWidget {
  const PingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ping',
      theme: ThemeData.dark(),
      home: const ChatScreen(),
    );
  }
}
