import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  runApp(const PingApp());
}

class PingApp extends StatelessWidget {
  const PingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PingHomePage(),
    );
  }
}

class PingHomePage extends StatefulWidget {
  const PingHomePage({super.key});

  @override
  State<PingHomePage> createState() => _PingHomePageState();
}

class _PingHomePageState extends State<PingHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  final List<ChatSession> _chatSessions = [];
  bool _isChatTab = true;
  bool _isGenerating = false;
  bool _didOpenWithSwipe = false;
  int _activeChatIndex = 0;
  int _chatCounter = 1;

  @override
  void initState() {
    super.initState();
    _chatSessions.add(
      ChatSession(
        id: 'chat-0',
        title: 'Chat 1',
        messages: <ChatMessage>[
          ChatMessage(role: MessageRole.user, text: 'Ola!'),
          ChatMessage(role: MessageRole.assistant, text: 'Lorem Ipsum'),
        ],
      ),
    );

    _inputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ChatSession get _activeChat => _chatSessions[_activeChatIndex];

  bool get _canSend {
    return _inputController.text.trim().isNotEmpty && !_isGenerating;
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _handleSwipeOpen(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    if (delta > 14 && !_didOpenWithSwipe) {
      _didOpenWithSwipe = true;
      _openMenu();
    }
  }

  void _resetSwipeGuard(DragEndDetails _) {
    _didOpenWithSwipe = false;
  }

  void _selectChat(int index) {
    setState(() {
      _activeChatIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _createChat() {
    setState(() {
      _chatCounter += 1;
      _chatSessions.insert(
        0,
        ChatSession(
          id: 'chat-${DateTime.now().microsecondsSinceEpoch}',
          title: 'Chat $_chatCounter',
          messages: <ChatMessage>[],
        ),
      );
      _activeChatIndex = 0;
    });
  }

  Future<void> _sendMessage() async {
    if (!_canSend) {
      return;
    }

    final prompt = _inputController.text.trim();
    _inputController.clear();

    setState(() {
      _isGenerating = true;
      _activeChat.messages.add(
        ChatMessage(role: MessageRole.user, text: prompt),
      );
      _activeChat.touch();
    });

    _scrollToBottom();
    await _streamFakeAnswer(chatId: _activeChat.id, prompt: prompt);

    if (!mounted) {
      return;
    }

    setState(() {
      _isGenerating = false;
    });
  }

  Future<void> _streamFakeAnswer({
    required String chatId,
    required String prompt,
  }) async {
    final session = _chatSessions.firstWhere((chat) => chat.id == chatId);
    final response = _buildFakeResponse(prompt);
    final assistantMessage = ChatMessage(role: MessageRole.assistant, text: '');

    setState(() {
      session.messages.add(assistantMessage);
      session.touch();
    });

    for (var i = 0; i < response.length; i++) {
      if (!mounted) {
        return;
      }

      await Future<void>.delayed(
        Duration(milliseconds: 18 + _random.nextInt(90)),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        assistantMessage.text += response[i];
      });
      _scrollToBottom();
    }
  }

  String _buildFakeResponse(String prompt) {
    const placeholders = <String>[
      'Perfeito. Ainda e um placeholder, mas ja consigo responder no fluxo do chat.',
      'Recebi sua mensagem. O stream esta fake por enquanto, com efeito de digitacao.',
      'Menu e chats locais estao ativos. No proximo passo conectamos uma IA real.',
      'Funciona! Podemos evoluir esse prompt para respostas mais contextuais depois.',
    ];

    if (prompt.toLowerCase().contains('miojo')) {
      return 'Para preparar miojo: ferva agua, cozinhe por 3 minutos e finalize com o tempero.';
    }

    return placeholders[_random.nextInt(placeholders.length)];
  }

  void _scrollToBottom() {
    scheduleMicrotask(() {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragUpdate: _handleSwipeOpen,
          onHorizontalDragEnd: _resetSwipeGuard,
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 20),
                Expanded(
                  child: _isChatTab
                      ? _buildChatBody()
                      : _buildPingPlaceholder(),
                ),
                const SizedBox(height: 10),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2D),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              _topTabButton(
                label: 'Ping',
                isSelected: !_isChatTab,
                onTap: () {
                  setState(() {
                    _isChatTab = false;
                  });
                },
              ),
              _topTabButton(
                label: 'Chat',
                isSelected: _isChatTab,
                onTap: () {
                  setState(() {
                    _isChatTab = true;
                  });
                },
              ),
            ],
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _openMenu,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2D),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(LucideIcons.menu, color: Colors.white, size: 23),
          ),
        ),
      ],
    );
  }

  Widget _topTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9D44BF) : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 31 / 2,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBody() {
    final messages = _activeChat.messages;
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Comece um novo chat no menu lateral.',
          style: TextStyle(color: Color(0xFF7F7F85), fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLastAssistant =
            message.role == MessageRole.assistant &&
            index == messages.length - 1;

        if (message.role == MessageRole.user) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF232428),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 31 / 2),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 36 / 2),
              ),
              if (isLastAssistant)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.copy,
                        size: 18,
                        color: Color(0xFFD7D7D7),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        LucideIcons.share2,
                        size: 18,
                        color: Color(0xFFD7D7D7),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        LucideIcons.rotateCcw,
                        size: 18,
                        color: Color(0xFFD7D7D7),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        LucideIcons.ellipsis,
                        size: 18,
                        color: Color(0xFFD7D7D7),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPingPlaceholder() {
    return const Center(
      child: Text(
        'Ping em desenvolvimento',
        style: TextStyle(color: Color(0xFF87878B), fontSize: 16),
      ),
    );
  }

  Widget _buildInputArea() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF232428),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1E23),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF35343A)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: TextField(
              controller: _inputController,
              enabled: !_isGenerating,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                hintText: 'Como preparar miojo?...',
                hintStyle: TextStyle(color: Color(0xFF5F6067)),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _canSend ? _sendMessage : null,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _canSend
                  ? const Color(0xFF9D44BF)
                  : const Color(0xFF18191D),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _canSend
                    ? const Color(0xFFAF68CD)
                    : const Color(0xFF35343A),
              ),
            ),
            child: Icon(
              LucideIcons.sendHorizontal,
              color: _canSend ? Colors.black : const Color(0xFF65656C),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.88,
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Row(
                children: const [
                  _StatPill(
                    icon: LucideIcons.flame,
                    label: '2',
                    color: Color(0xFFFF6B77),
                  ),
                  SizedBox(width: 10),
                  _StatPill(
                    icon: LucideIcons.zap,
                    label: '68%',
                    color: Color(0xFFE4C746),
                  ),
                  Spacer(),
                  _CounterPill(text: '10/20'),
                ],
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recentes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 31 / 2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _chatSessions.length,
                  itemBuilder: (context, index) {
                    final chat = _chatSessions[index];
                    final isSelected = index == _activeChatIndex;

                    return InkWell(
                      onTap: () => _selectChat(index),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2A2A2D)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.flaskConical,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                chat.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34 / 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _createChat,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D44BF),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.penLine, color: Colors.black, size: 21),
                      SizedBox(width: 10),
                      Text(
                        'Novo Chat',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum MessageRole { user, assistant }

class ChatMessage {
  ChatMessage({required this.role, required this.text});

  final MessageRole role;
  String text;
}

class ChatSession {
  ChatSession({required this.id, required this.title, required this.messages});

  final String id;
  String title;
  final List<ChatMessage> messages;
  DateTime updatedAt = DateTime.now();

  void touch() {
    updatedAt = DateTime.now();
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF212226),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF212226),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    );
  }
}
