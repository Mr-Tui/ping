import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../enums/message_sender.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;

  const MessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        return Align(
          alignment: message.sender == MessageSender.user
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: message.sender == MessageSender.user
                  ? Colors.purple
                  : Colors.grey[900],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
