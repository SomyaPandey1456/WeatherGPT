import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_context.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/suggestion_chip.dart';

/// A single stored conversation session shown in the history sidebar.
class _ConversationSession {
  final String id;
  final String title;
  final DateTime timestamp;
  final List<ChatMessage> messages;

  _ConversationSession({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messages,
  });
}

class ChatScreen extends StatefulWidget {
  final String? initialQuery;

  const ChatScreen({super.key, this.initialQuery});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isListeningVoice = false;

  // ── History sidebar state ────────────────────────────────────────────────
  final List<_ConversationSession> _history = [];
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _startNewSession();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleUserSubmit(widget.initialQuery!);
      });
    }
  }

  /// Create a fresh in-memory session.
  void _startNewSession() {
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages = [];
  }

  /// Save the current conversation to history, then clear for a new chat.
  void _saveCurrentAndStartNew() {
    if (_messages.isNotEmpty) {
      final title = _messages.first.isUser
          ? _messages.first.text
          : _messages.first.text;
      final session = _ConversationSession(
        id: _currentSessionId!,
        title: title.length > 50 ? '${title.substring(0, 50)}…' : title,
        timestamp: _messages.first.timestamp,
        messages: List.from(_messages),
      );
      setState(() {
        _history.insert(0, session);
        _startNewSession();
      });
    }
  }

  /// Reload a previous session from history into the main view.
  void _loadSession(_ConversationSession session) {
    // Save current if any
    if (_messages.isNotEmpty) {
      final title = _messages.first.isUser
          ? _messages.first.text
          : _messages.first.text;
      final current = _ConversationSession(
        id: _currentSessionId!,
        title: title.length > 50 ? '${title.substring(0, 50)}…' : title,
        timestamp: _messages.first.timestamp,
        messages: List.from(_messages),
      );
      // Only add if not already in history
      if (!_history.any((h) => h.id == _currentSessionId)) {
        _history.insert(0, current);
      }
    }

    setState(() {
      _currentSessionId = session.id;
      _messages = List.from(session.messages);
    });

    Navigator.pop(context); // close drawer
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _handleUserSubmit(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage.user(text.trim());
    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final aiResponse = await _chatService.sendQuery(text.trim());
      if (mounted) {
        setState(() {
          _messages.add(aiResponse);
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage.ai(
            'I experienced a connection issue reaching WeatherGPT servers. Please try asking again.',
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleVoiceInput() {
    setState(() {
      _isListeningVoice = !_isListeningVoice;
    });

    if (_isListeningVoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Listening... Say your weather question now.')),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isListeningVoice) {
          setState(() {
            _isListeningVoice = false;
          });
          _handleUserSubmit('Will it rain in Greater Noida today?');
        }
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── History Drawer ───────────────────────────────────────────────────────

  Widget _buildHistoryDrawer() {
    return Drawer(
      width: 300,
      backgroundColor: context.scaffoldBg,
      child: Column(
        children: [
          // Drawer header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F62FE), Color(0xFF0091FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Chat History',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your previous conversations',
                  style: TextStyle(color: Color(0xFFCCDEFF), fontSize: 13),
                ),
              ],
            ),
          ),

          // New Chat button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _saveCurrentAndStartNew();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded,
                    color: AppColors.primaryBlue, size: 18),
                label: const Text(
                  'New Conversation',
                  style: TextStyle(
                      color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: context.borderBg),

          // History list
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 48, color: context.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No previous conversations',
                            style: TextStyle(
                                color: context.textMuted,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start chatting and your\nhistory will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _history.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, indent: 16, endIndent: 16, color: context.borderBg),
                    itemBuilder: (context, index) {
                      final session = _history[index];
                      final isActive = session.id == _currentSessionId;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: isActive
                              ? (context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight)
                              : context.surfaceVariantBg,
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: isActive
                                ? AppColors.primaryBlue
                                : context.textMuted,
                          ),
                        ),
                        title: Text(
                          session.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.primaryBlue
                                : context.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${session.messages.length} messages · ${_formatDate(session.timestamp)}',
                          style: TextStyle(
                              fontSize: 11, color: context.textMuted),
                        ),
                        selected: isActive,
                        selectedTileColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onTap: () => _loadSession(session),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              size: 18, color: context.textMuted),
                          tooltip: 'Delete',
                          onPressed: () {
                            setState(() => _history.removeAt(index));
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Main build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.scaffoldBg,
      drawer: _buildHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Icon(Icons.menu_rounded, color: context.textPrimary),
          tooltip: 'Chat History',
        ),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded,
                color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              'WeatherGPT Assistant',
              style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _saveCurrentAndStartNew,
            icon: Icon(Icons.add_comment_outlined, color: context.textPrimary),
            tooltip: 'New Chat',
          ),
          IconButton(
            onPressed: () {
              if (_messages.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Chat'),
                    content: const Text(
                        'Clear the current conversation? This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _messages.clear());
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear',
                            style: TextStyle(color: AppColors.criticalRed)),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: Icon(Icons.delete_outline_rounded, color: context.textPrimary),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Voice Listening Wave Indicator Banner
          if (_isListeningVoice)
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: AppColors.primaryBlue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.graphic_eq_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'WeatherGPT is listening... Speak your question',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),

          // Message History Area
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChatState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubbleWidget(
                        message: _messages[index],
                        onQuerySelected: _handleUserSubmit,
                      );
                    },
                  ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 10),
                  Text('WeatherGPT is thinking...',
                      style: TextStyle(
                          fontSize: 13, color: context.textMuted)),
                ],
              ),
            ),

          // Suggested Prompts Row
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: context.cardBg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AppStrings.defaultSuggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SuggestionChipWidget(
                      text: suggestion,
                      onTap: () => _handleUserSubmit(suggestion),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Divider(height: 1, color: context.borderBg),

          // Bottom Input Bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: context.cardBg,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: _toggleVoiceInput,
                    icon: Icon(
                      _isListeningVoice
                          ? Icons.mic_rounded
                          : Icons.mic_none_rounded,
                      color: _isListeningVoice
                          ? AppColors.criticalRed
                          : AppColors.primaryBlue,
                    ),
                    tooltip: 'Voice Search',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      onSubmitted: _handleUserSubmit,
                      style: TextStyle(color: context.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Ask WeatherGPT anything...',
                        hintStyle: TextStyle(color: context.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () =>
                          _handleUserSubmit(_inputController.text),
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                      constraints: const BoxConstraints(
                          minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                      tooltip: 'Send Message',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 48, color: context.isDark ? AppColors.skyBlue : AppColors.primaryBlue),
            ),
            const SizedBox(height: 20),
            Text(
              'Hi! I\'m WeatherGPT',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about weather, rain alerts, forecasts, travel safety, or climate trends in India.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: context.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            // History hint if there are past sessions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_rounded,
                    size: 16, color: context.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Tap the menu icon to access chat history',
                  style: TextStyle(
                      fontSize: 12, color: context.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
