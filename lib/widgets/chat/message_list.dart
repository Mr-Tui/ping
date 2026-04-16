import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../enums/message_sender.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        return Align(
          alignment: message.sender == MessageSender.user
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.sender == MessageSender.user
                    ? Colors.grey[900]
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
