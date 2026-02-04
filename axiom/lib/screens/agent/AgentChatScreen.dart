import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:axiom/providers/ProjectProvider.dart';
import 'package:axiom/services/project_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AgentChatScreen extends StatefulWidget {
  const AgentChatScreen({super.key});

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentProjectId;

  // Agent API endpoint
  static const String _agentUrl = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    _addMessage(AgentMessage(
        text: '🤖 Hello! I\'m your Axiom AI assistant. I can help you create projects, APIs, and widgets through natural language.\n\nTry:\n• "Create a new project called Task Manager"\n• "Add CRUD API for tasks"\n• "Add a submit button"',
        isUser: false));
    _checkAgentStatus();
  }

  Future<void> _checkAgentStatus() async {
    try {
      final response = await http.get(Uri.parse('$_agentUrl/health'));
      if (response.statusCode == 200) {
        _addMessage(AgentMessage(
            text: '✅ Agent is ready! Backend connected.',
            isUser: false));
      } else {
        _addMessage(AgentMessage(
            text: '⚠️ Agent is starting up...',
            isUser: false));
      }
    } catch (e) {
      _addMessage(AgentMessage(
          text: '❌ Agent not running. Please start the agent first.\nRun: python main-minimal.py',
          isUser: false));
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addMessage(ChatMessage(text: message, isUser: true));
    _messageController.clear();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$_agentUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'project_id': _currentProjectId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        _addMessage(AgentMessage(
            text: data['message'],
            isUser: false));

        // Update project ID if returned
        if (data['data'] != null && data['data']['project_id'] != null) {
          setState(() {
            _currentProjectId = data['data']['project_id'];
          });
          _addMessage(AgentMessage(
              text: '📱 Working on project: ${data['data']['project_id']}',
              isUser: false));
        }

        // Show detailed results
        if (data['data'] != null && data['data']['results'] != null) {
          for (final result in data['data']['results']) {
            if (result['success']) {
              _addMessage(AgentMessage(
                  text: '✅ ${result['message']}',
                  isUser: false));
            } else {
              _addMessage(AgentMessage(
                  text: '❌ ${result['error']}',
                  isUser: false));
            }
          }
        }
      } else {
        _addMessage(AgentMessage(
            text: '❌ Error: ${data['error']}',
            isUser: false));
      }
    } catch (e) {
      _addMessage(AgentMessage(
          text: '❌ Connection error: ${e.toString()}',
          isUser: false));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Axiom AI Agent'),
            if (_currentProjectId != null)
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Project: $_currentProjectId',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Quick Actions Sidebar
          Container(
            width: 300,
            color: Colors.grey[50],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF4A90E2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to send common commands',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildQuickAction(
                        '📱 Create Task Manager App',
                        'Create a new project called Task Manager',
                        Icons.app_registration,
                      ),
                      _buildQuickAction(
                        '🔌 Add Task API',
                        'Create CRUD API for tasks with title and description',
                        Icons.api,
                      ),
                      _buildQuickAction(
                        '📝 Add Task Form',
                        'Add a form with title and description fields',
                        Icons.text_fields,
                      ),
                      _buildQuickAction(
                        '🔗 Connect Form to API',
                        'Connect submit button to task creation API',
                        Icons.link,
                      ),
                      _buildQuickAction(
                        '📋 List Projects',
                        'Show me all projects',
                        Icons.list,
                      ),
                      const SizedBox(height: 16),
                      if (_currentProjectId != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Project',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              Text(
                                _currentProjectId!,
                                style: TextStyle(
                                  color: Colors.green[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chat Area
          Expanded(
            child: Column(
              children: [
                // Messages
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
                  ),
                ),
                // Input Area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Ask me to create a project, API, or widget...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        FloatingActionButton(
                          onPressed: _sendMessage,
                          backgroundColor: const Color(0xFF4A90E2),
                          mini: true,
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, String message, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _sendQuickMessage(message),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF4A90E2), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A90E2),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF4A90E2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser ? const Radius.circular(4) : null,
                  bottomLeft: !message.isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AgentMessage extends ChatMessage {
  AgentMessage({required super.text, required super.isUser});
}
