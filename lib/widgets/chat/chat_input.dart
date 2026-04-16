import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  bool _isSendButtonEnabled(String text) {
    return text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: Center(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[900],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final isEnabled = _isSendButtonEnabled(value.text);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? Colors.white
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isEnabled
                        ? Colors.white
                        : const Color.fromARGB(255, 60, 40, 65),
                    width: 2,
                  ),
                ),

                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                  },

                  child: IconButton(
                    key: ValueKey(isEnabled),
                    icon: Icon(
                      LucideIcons.sendHorizontal,
                      color: isEnabled
                          ? Colors.black
                          : const Color.fromARGB(255, 60, 40, 65),
                    ),
                    onPressed: isEnabled
                        ? () => onSend(value.text)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}