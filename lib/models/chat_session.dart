import '../enums/input_mode.dart';
import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final ChatInputMode mode;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.mode,
    required this.messages,
  });
}
