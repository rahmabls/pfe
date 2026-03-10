import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false; // indicateur "IA en train d'écrire"

  // Questions rapides suggérées
  static const List<String> _suggestions = [
    "☁️ Météo aujourd'hui ?",
    "🌧️ Va-t-il pleuvoir ?",
    "💨 Vent fort prévu ?",
    "🔥 Risque de canicule ?",
    "🌡️ Température dans 24h ?",
  ];

  Future<void> _sendMessage([String? text]) async {
    final userMessage = (text ?? _controller.text).trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botReply = data["response"]?.toString() ??
            data["error"]?.toString() ??
            "Réponse vide du serveur";

        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(text: botReply, isUser: false));
        });
      } else {
        _addError("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      _addError("Impossible de contacter le serveur.");
    }

    _scrollToBottom();
  }

  void _addError(String msg) {
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: msg, isUser: false));
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF6A4CFF)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(message.text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // Indicateur "IA en train d'écrire..."
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(0),
            const SizedBox(width: 4),
            _dot(1),
            const SizedBox(width: 4),
            _dot(2),
          ],
        ),
      ),
    );
  }

  Widget _dot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 150),
      builder: (_, val, __) => Opacity(
        opacity: val,
        child: const CircleAvatar(radius: 4, backgroundColor: Colors.white54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1F3B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A1A6E),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF6A4CFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Assistant IA", style: TextStyle(fontSize: 16)),
                Text("Météo Béni Mellal", style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Messages ──────────────────────────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),

          // ── Suggestions rapides ───────────────────────────────────────
          if (_messages.isEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: _suggestions.map((s) {
                  return GestureDetector(
                    onTap: () => _sendMessage(s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A4CFF).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF6A4CFF).withOpacity(0.6)),
                      ),
                      child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 8),

          // ── Saisie ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF0D0F1E),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Posez votre question météo...",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6A4CFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Écran d'accueil chat ──────────────────────────────────────────────────
  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6A4CFF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Color(0xFF6A4CFF), size: 60),
          ),
          const SizedBox(height: 20),
          const Text(
            "Assistant Météo IA",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Posez vos questions sur la météo\nde Béni Mellal",
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
