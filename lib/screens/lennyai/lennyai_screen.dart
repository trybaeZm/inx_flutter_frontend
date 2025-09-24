import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/api_service.dart';
import '../../core/services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/business_provider.dart';
import '../../widgets/common/responsive_wrapper.dart';

class LennyAiScreen extends StatefulWidget {
  const LennyAiScreen({Key? key}) : super(key: key);

  @override
  State<LennyAiScreen> createState() => _LennyAiScreenState();
}

class _LennyAiScreenState extends State<LennyAiScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  String _userId = '';
  String _userName = '';
  String _sessionId = '';
  String? _businessId;

  bool _loading = false;
  List<Map<String, String>> _messages = [
    {'role': 'bot', 'content': '👋 Ask me anything about your business!'},
  ];
  List<Map<String, dynamic>> _recent = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _sessionId = const Uuid().v4();
    });
    
    // Get the currently authenticated user
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      // User not authenticated, show error
      setState(() {
        _messages = [{'role': 'bot', 'content': '⚠️ Please sign in to use LennyAI. Only authenticated users can access their business data.'}];
      });
      return;
    }
    
    setState(() {
      _userId = user.id;
      _userName = user.userMetadata?['full_name'] ?? user.email ?? 'User';
    });
    
    // Load user's recent conversations
    await _loadRecent();
  }

  Future<void> _loadRecent() async {
    if (_userId.isEmpty) return;
    
    // Validate user is still authenticated
    if (!_validateUserAuthentication()) {
      return;
    }
    
    try {
      final recent = await _api.lennyRecentQuestions(userId: _userId);
      setState(() => _recent = recent);
    } catch (_) {}
  }

  Future<void> _sendMessage([String? custom]) async {
    final text = (custom ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;
    
    // Validate user is still authenticated
    if (!_validateUserAuthentication()) {
      return;
    }
    
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _controller.clear();
      _loading = true;
    });
    _scrollToBottom();
    
    try {
      // Show connecting message
      setState(() {
        _messages.add({'role': 'bot', 'content': '🤖 Connecting to RAG Backend...'});
      });
      _scrollToBottom();
      
      final reply = await _api.lennyQuery(
        question: text,
        sessionId: _sessionId,
        userId: _userId,
        userName: _userName,
      );
      
      // Remove connecting message and add real response
      setState(() {
        _messages.removeLast(); // Remove connecting message
        _messages.add({'role': 'bot', 'content': reply.isNotEmpty ? reply : '⚠️ No response from RAG Backend.'});
      });
    } catch (e) {
      // Remove connecting message and add error
      setState(() {
        _messages.removeLast(); // Remove connecting message
        _messages.add({'role': 'bot', 'content': '⚠️ Error connecting to RAG Backend: ${e.toString()}'});
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
      _loadRecent();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _testConnection() async {
    try {
      final result = await _api.testRagBackendConnection();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Connection test completed'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Validate that the user is still authenticated and has access
  bool _validateUserAuthentication() {
    final currentUser = SupabaseService.client.auth.currentUser;
    if (currentUser == null || currentUser.id != _userId) {
      setState(() {
        _messages.add({'role': 'bot', 'content': '⚠️ Authentication expired. Please sign in again to continue using LennyAI.'});
      });
      return false;
    }
    return true;
  }

  // Upload flow removed per request

  Future<void> _loadSession(String sessionId) async {
    try {
      final items = await _api.lennyChatSession(sessionId: sessionId, userId: _userId);
      if (items.isEmpty) {
        setState(() => _messages = [{'role': 'bot', 'content': '⚠️ No messages found for this session.'}]);
        return;
      }
      final msgs = <Map<String, String>>[];
      for (final chat in items) {
        msgs.add({'role': 'user', 'content': (chat['question'] ?? '').toString()});
        msgs.add({'role': 'bot', 'content': (chat['answer'] ?? '').toString()});
      }
      setState(() {
        _messages = msgs;
        _sessionId = sessionId;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _messages = [{'role': 'bot', 'content': '⚠️ Error loading session.'}]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    // Read selected business once per build (no rebuild wiring here to keep it simple)
    try {
      final container = ProviderScope.containerOf(context);
      final b = container.read(selectedBusinessProvider);
      _businessId = b?.id;
    } catch (_) {}

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('LennyAi'),
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          // Test connection button
          IconButton(
            onPressed: _testConnection,
            icon: const Icon(Icons.wifi_find_rounded),
            tooltip: 'Test RAG Backend Connection',
          ),
          // New chat button
          IconButton(
            onPressed: () {
              setState(() {
                _sessionId = const Uuid().v4();
                _messages = [{'role': 'bot', 'content': '👋 Ask me anything about your business!'}];
              });
            },
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: isMobile ? _buildMobileLayout(theme, isDark) : _buildDesktopLayout(theme, isDark),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Recent questions section (collapsible on mobile)
        ExpansionTile(
          title: Row(
            children: [
              Icon(Icons.history, size: 18, color: isDark ? Colors.grey[300] : Colors.grey[700]),
              const SizedBox(width: 8),
              Text('Recent Questions', style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.grey[200] : Colors.black87,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                itemCount: _recent.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                itemBuilder: (context, index) {
                  final item = _recent[index];
                  final q = (item['question'] ?? '').toString();
                  final sid = (item['session_id'] ?? '').toString();
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.chat_bubble_outline, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                    title: Text(
                      q.isEmpty ? '—' : (q.length > 48 ? '${q.substring(0, 48)}…' : q),
                      style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.grey[200] : Colors.black87),
                    ),
                    onTap: sid.isEmpty ? null : () => _loadSession(sid),
                  );
                },
              ),
            ),
          ],
        ),
        
        // Main chat area
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0B1220) : Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_loading && index == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white70 : Colors.black54),
                                ),
                                const SizedBox(width: 8),
                                Text('Lenny is thinking…', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black54)),
                              ],
                            ),
                          ),
                        );
                      }
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                          decoration: BoxDecoration(
                            color: isUser
                                ? (isDark ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB)).withOpacity(0.14)
                                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['content'] ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isUser ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.grey[200] : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Ask Lenny anything about your business…',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _sendMessage,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Send'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, bool isDark) {
    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: 280,
        child: Card(
            color: isDark ? const Color(0xFF111827) : Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                      Icon(Icons.history, size: 18, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      const SizedBox(width: 6),
                      Text('Recent', style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.grey[200] : Colors.black87,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _recent.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final item = _recent[index];
                        final q = (item['question'] ?? '').toString();
                        final sid = (item['session_id'] ?? '').toString();
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.chat_bubble_outline, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 18),
                          title: Text(
                            q.isEmpty ? '—' : (q.length > 48 ? '${q.substring(0, 48)}…' : q),
                            style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.grey[200] : Colors.black87),
                          ),
                          onTap: sid.isEmpty ? null : () => _loadSession(sid),
                        );
                      },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        const SizedBox(width: 12),
        
        // Main chat
        Expanded(
          child: Card(
            color: isDark ? const Color(0xFF0B1220) : Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_loading && index == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white70 : Colors.black54),
                                ),
                                const SizedBox(width: 8),
                                Text('Lenny is thinking…', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black54)),
                              ],
                            ),
                          ),
                        );
                      }
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 800),
                          decoration: BoxDecoration(
                            color: isUser
                                ? (isDark ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB)).withOpacity(0.14)
                                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['content'] ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isUser ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.grey[200] : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Ask Lenny anything about your business…',
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _sendMessage,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Send'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


