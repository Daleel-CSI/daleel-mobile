// lib/screens/ai_chat_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'role': 'ai',
        'content': {
          'service': 'مرحباً بك في Daleel AI 👋',
          'category': '',
          'steps': [
            'اكتب أي خدمة حكومية تريدها (جواز سفر، بطاقة تموين، رخصة قيادة...)',
          ],
          'documents': [],
        },
      });
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final aiData = await _api.getAiResponse(text);

      setState(() {
        _messages.add({'role': 'ai', 'content': aiData});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'content': {
            'service': 'خطأ',
            'steps': ['حدث خطأ في الاتصال بالذكاء الاصطناعي'],
            'documents': [],
          }
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  Widget _buildAiMessage(Map<String, dynamic> data) {
    final service = data['service']?.toString() ?? 'خدمة حكومية';
    final category = data['category']?.toString() ?? '';
    final steps = data['steps'] as List? ?? [];
    final documents = data['documents'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(service,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (category.isNotEmpty)
          Text('📂 $category',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 12),

        if (steps.isNotEmpty) ...[
          const Text('الخطوات المطلوبة:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $step', style: const TextStyle(height: 1.4)),
              )),
        ],

        if (documents.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('المستندات المطلوبة:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...documents.map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $doc', style: const TextStyle(height: 1.4)),
              )),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF379777)),
                  ),
                  const Expanded(
                    child: Text(
                      'Daleel AI',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.smart_toy_rounded,
                      color: Color(0xFF379777), size: 28),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return const Row(
                      children: [
                        CircularProgressIndicator(strokeWidth: 2.5),
                        SizedBox(width: 12),
                        Text('Daleel AI بيفكر...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    );
                  }

                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF379777)
                            : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isUser
                          ? Text(
                              msg['content'].toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            )
                          : _buildAiMessage(msg['content']),
                    ),
                  );
                },
              ),
            ),

            // Input Field
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'اكتب سؤالك عن أي خدمة...',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFF379777),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}