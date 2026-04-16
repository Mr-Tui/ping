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
  final ScrollController scrollController = ScrollController();

  bool isNearBottom() {
    if (!scrollController.hasClients) return true;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    return (maxScroll - currentScroll) < 100;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

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

    if (isNearBottom()) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MessageList(messages: messages, scrollController: scrollController),
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
