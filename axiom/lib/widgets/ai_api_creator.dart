import 'package:flutter/material.dart';
import 'package:axiom/services/ai_service.dart';
import 'package:axiom/models/ApiEndpointmodel.dart';

class AIApiCreatorDialog extends StatefulWidget {
  const AIApiCreatorDialog({super.key});

  @override
  State<AIApiCreatorDialog> createState() => _AIApiCreatorDialogState();
}

class _AIApiCreatorDialogState extends State<AIApiCreatorDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _generatedConfig;
  List<String> _suggestions = [];

  Future<void> _generateAPI() async {
    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please enter a description');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final config = await AIService.generateAPIFromDescription(_descriptionController.text);
      setState(() {
        _generatedConfig = config;
        _suggestions = [];
      });
    } catch (e) {
      _showError('Failed to generate API: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getSuggestions() async {
    if (_generatedConfig == null) return;

    try {
      final suggestions = await AIService.getAPIImprovements(_generatedConfig!);
      setState(() => _suggestions = suggestions);
    } catch (e) {
      _showError('Failed to get suggestions: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Fixed height
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'AI API Creator',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content - Scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Description Input
                    const Text(
                      'Describe the API you want to create:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Example: contact form with name, email, message',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _generateAPI,
                        icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                        label: Text(_isLoading ? 'Generating...' : 'Generate API'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    // Generated Configuration
                    if (_generatedConfig != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Generated Configuration:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Name', _generatedConfig!['name']),
                            _buildInfoRow('Method', _generatedConfig!['method']),
                            _buildInfoRow('Path', _generatedConfig!['path']),
                            _buildInfoRow('Purpose', _generatedConfig!['purpose']),
                            _buildInfoRow('Collection', _generatedConfig!['collection']),
                            _buildInfoRow('Auth', _generatedConfig!['auth'].toString()),
                            
                            if (_generatedConfig!['fields'] != null) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Fields:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...(_generatedConfig!['fields'] as List).map((field) => 
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, top: 4),
                                  child: Text(
                                    '• ${field['name']} (${field['type']})${field['required'] ? ' *' : ''}',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
                              ).toList(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _getSuggestions,
                              icon: const Icon(Icons.lightbulb),
                              label: const Text('Get Suggestions'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context, _generatedConfig),
                              icon: const Icon(Icons.check),
                              label: const Text('Use This API'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Suggestions
                    if (_suggestions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'AI Suggestions:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _suggestions.map((suggestion) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                                const SizedBox(width: 8),
                                Expanded(child: Text(suggestion)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
