import '../enums/message_sender.dart';

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
  });
}
