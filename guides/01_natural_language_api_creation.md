# 🤖 Feature #1: Natural Language API Creation

## 🎯 **Overview**
Allow users to create API endpoints by typing natural language descriptions instead of filling complex forms. Example: "I need an API to save user feedback with name, email, rating, and comments"

## ⏱️ **Implementation Time**: 2-3 hours

## 🛠️ **Files to Modify**

### Backend Files:
- `axiomBackend/src/services/aiService.js` (NEW)
- `axiomBackend/src/services/openaiClient.js` (NEW)  
- `axiomBackend/src/routes/aiApiRoutes.js` (NEW)

### Frontend Files:
- `axiom/lib/services/ai_service.dart` (NEW)
- `axiom/lib/screens/APIManagementScreen.dart` (MODIFY)
- `axiom/lib/widgets/ai_api_creator.dart` (NEW)

---

## 🚀 **Step 1: Backend AI Service Setup**

### Create OpenAI Client Wrapper
```javascript
// axiomBackend/src/services/openaiClient.js
import OpenAI from 'openai';

class OpenAIClient {
  constructor() {
    this.client = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  async generateAPIFromDescription(description) {
    const prompt = `
You are an API generation assistant. Convert this natural language description into a structured API configuration.

Description: "${description}"

Return a JSON object with:
{
  "name": "API Name",
  "method": "GET|POST|PUT|DELETE",
  "path": "/api/path",
  "purpose": "create|read|update|delete|list",
  "collection": "mongodb_collection_name",
  "fields": [
    {
      "name": "field_name",
      "type": "string|number|email|boolean",
      "required": true|false,
      "description": "Field description"
    }
  ],
  "auth": true|false
}

Only return valid JSON, no explanations.
`;

    try {
      const response = await this.client.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.3,
      });

      const content = response.choices[0].message.content;
      return JSON.parse(content);
    } catch (error) {
      console.error('OpenAI API Error:', error);
      throw new Error('Failed to generate API configuration');
    }
  }
}

export default new OpenAIClient();
```

### Create AI Service
```javascript
// axiomBackend/src/services/aiService.js
import openaiClient from './openaiClient.js';

class AIService {
  async generateAPIConfig(description) {
    try {
      console.log('🤖 Generating API config for:', description);
      
      const config = await openaiClient.generateAPIFromDescription(description);
      
      // Validate and enhance the configuration
      return this.validateAndEnhanceConfig(config);
    } catch (error) {
      console.error('AI Service Error:', error);
      throw error;
    }
  }

  validateAndEnhanceConfig(config) {
    // Ensure required fields exist
    if (!config.name) config.name = 'Generated API';
    if (!config.method) config.method = 'POST';
    if (!config.path) config.path = '/api/generated';
    if (!config.purpose) config.purpose = 'create';
    if (!config.collection) config.collection = 'generated_data';
    
    // Add default validation
    config.fields = config.fields || [];
    config.auth = config.auth || false;
    
    return config;
  }

  async suggestAPIImprovements(existingConfig) {
    const prompt = `
Analyze this API configuration and suggest improvements:

${JSON.stringify(existingConfig, null, 2)}

Suggest improvements for:
1. Security
2. Performance
3. Data validation
4. Error handling

Return suggestions as a JSON array of strings.
`;

    try {
      const response = await openaiClient.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.3,
      });

      const content = response.choices[0].message.content;
      return JSON.parse(content);
    } catch (error) {
      console.error('Suggestion generation failed:', error);
      return [];
    }
  }
}

export default new AIService();
```

### Create AI API Routes
```javascript
// axiomBackend/src/routes/aiApiRoutes.js
import { Router } from 'express';
import aiService from '../services/aiService.js';

const router = Router();

// Generate API from natural language
router.post('/generate-api', async (req, res) => {
  try {
    const { description } = req.body;
    
    if (!description) {
      return res.status(400).json({ 
        error: 'Description is required' 
      });
    }

    const apiConfig = await aiService.generateAPIConfig(description);
    
    res.json({
      success: true,
      data: apiConfig
    });
  } catch (error) {
    console.error('Generate API Error:', error);
    res.status(500).json({ 
      error: 'Failed to generate API configuration',
      message: error.message 
    });
  }
});

// Get API suggestions
router.post('/suggest-improvements', async (req, res) => {
  try {
    const { apiConfig } = req.body;
    
    if (!apiConfig) {
      return res.status(400).json({ 
        error: 'API configuration is required' 
      });
    }

    const suggestions = await aiService.suggestAPIImprovements(apiConfig);
    
    res.json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    console.error('Suggestions Error:', error);
    res.status(500).json({ 
      error: 'Failed to generate suggestions',
      message: error.message 
    });
  }
});

export default router;
```

### Update Server to Include AI Routes
```javascript
// In axiomBackend/src/server.js, add:
import aiApiRoutes from './routes/aiApiRoutes.js';

// Add this line with other routes:
app.use('/api/ai', aiApiRoutes);
```

---

## 📱 **Step 2: Frontend AI Service**

### Create AI Service for Flutter
```dart
// axiom/lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = 'http://localhost:5000/api/ai';

  static Future<Map<String, dynamic>> generateAPIFromDescription(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-api'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        } else {
          throw Exception(data['error'] ?? 'Failed to generate API');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }

  static Future<List<String>> getAPIImprovements(Map<String, dynamic> apiConfig) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suggest-improvements'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'apiConfig': apiConfig,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<String>.from(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get suggestions');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }
}
```

---

## 🎨 **Step 3: AI API Creator Widget**

### Create AI API Creator Dialog
```dart
// axiom/lib/widgets/ai_api_creator.dart
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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'AI API Creator',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description Input
            const Text(
              'Describe the API you want to create:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Example: I need an API to save user feedback with name, email, rating, and comments',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Generate Button
            ElevatedButton.icon(
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
              ),
            ),
            const SizedBox(height: 24),

            // Generated Configuration
            if (_generatedConfig != null) ...[
              const Text(
                'Generated Configuration:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Name', _generatedConfig!['name']),
                        _buildInfoRow('Method', _generatedConfig!['method']),
                        _buildInfoRow('Path', _generatedConfig!['path']),
                        _buildInfoRow('Purpose', _generatedConfig!['purpose']),
                        _buildInfoRow('Collection', _generatedConfig!['collection']),
                        _buildInfoRow('Authentication', _generatedConfig!['auth'].toString()),
                        
                        if (_generatedConfig!['fields'] != null) ...[
                          const SizedBox(height: 12),
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
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _getSuggestions,
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('Get Suggestions'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, _generatedConfig),
                    icon: const Icon(Icons.check),
                    label: const Text('Use This API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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
              ..._suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(child: Text(suggestion)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔧 **Step 4: Update API Management Screen**

### Modify API Management Screen
```dart
// In axiom/lib/screens/APIManagementScreen.dart, add this to the AppBar actions:

AppBar(
  title: const Text('API Management'),
  actions: [
    // AI Creator Button
    IconButton(
      icon: const Icon(Icons.auto_awesome),
      onPressed: () async {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => const AIApiCreatorDialog(),
        );

        if (result != null && context.mounted) {
          // Convert AI config to ApiEndpoint and create it
          final apiEndpoint = _convertAIConfigToApiEndpoint(result);
          final success = await context.read<ApiProvider>().createAPI(apiEndpoint);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success ? '✅ AI-generated API created successfully' : '❌ Failed to create API',
                ),
              ),
            );
          }
        }
      },
      tooltip: 'Create API with AI',
    ),
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => Utils().showAddAPIDialog(context),
    ),
  ],
),
```

### Add Helper Method
```dart
// Add this method to APIManagementScreen.dart
ApiEndpoint _convertAIConfigToApiEndpoint(Map<String, dynamic> config) {
  return ApiEndpoint(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: config['name'] ?? 'Generated API',
    method: config['method'] ?? 'POST',
    path: config['path'] ?? '/api/generated',
    purpose: config['purpose'] ?? 'create',
    collectionName: config['collection'] ?? 'generated_data',
    auth: config['auth'] ?? false,
    fields: (config['fields'] as List<dynamic>?)?.map((field) => {
      'name': field['name'],
      'type': field['type'],
      'required': field['required'] ?? false,
      'description': field['description'] ?? '',
    }).toList() ?? [],
  );
}
```

---

## 🧪 **Step 5: Testing**

### Test the AI API Creation:

1. **Start Backend Server**
   ```bash
   cd axiomBackend
   npm run dev
   ```

2. **Start Flutter App**
   ```bash
   cd axiom
   flutter run
   ```

3. **Test AI API Creation**
   - Open API Management screen
   - Click the AI (🤖) button
   - Enter: "I need an API to save customer orders with product name, quantity, and price"
   - Click "Generate API"
   - Review the generated configuration
   - Click "Use This API"

4. **Verify API Creation**
   - Check if the API appears in your API list
   - Test the API functionality
   - Verify it works with form submissions

### Test Different Descriptions:
- "Create an endpoint to register users with email and password"
- "I need to get all products from the database"
- "Update customer information with name, email, and phone"

---

## 🐛 **Common Issues & Solutions**

### Issue 1: OpenAI API Key Not Found
**Solution**: Add `OPENAI_API_KEY=your_key_here` to your `.env` file

### Issue 2: AI Returns Invalid JSON
**Solution**: The AI service includes error handling and validation

### Issue 3: Generated API Not Working
**Solution**: Check the browser console and backend logs for errors

### Issue 4: Frontend-Backend Connection
**Solution**: Ensure both are running and check the API URL in `ai_service.dart`

---

## ✅ **Success Criteria**

- [ ] Users can create APIs by typing natural language descriptions
- [ ] AI generates valid API configurations with proper fields
- [ ] Generated APIs work correctly with the dynamic API system
- [ ] Users can get AI suggestions for API improvements
- [ ] Error handling works gracefully
- [ ] UI is intuitive and responsive

---

## 🎉 **Next Steps**

Once this feature is working, proceed to **Feature #2: Smart Form Validation** by opening `guides/02_smart_form_validation.md`.

**Congratulations! You've added AI-powered API creation to your no-code platform!** 🚀
