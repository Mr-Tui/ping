import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../enums/message_sender.dart';
import '../../widgets/chat/message_list.dart';
import '../../widgets/chat/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController controller = TextEditingController();

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: text,
          sender: MessageSender.user,
          createdAt: DateTime.now(),
        ),
      );
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MessageList(messages: messages),
            ),
            ChatInput(
              controller: controller,
              onSend: sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
