# 🧠 Feature #2: Smart Form Validation

## 🎯 **Overview**
Implement AI-powered form validation that understands context and provides intelligent error messages. Instead of basic required field checks, AI will validate data patterns, business logic, and provide helpful suggestions.

## ⏱️ **Implementation Time**: 1-2 hours

## 🛠️ **Files to Modify**

### Backend Files:
- `axiomBackend/src/services/validationService.js` (NEW)
- `axiomBackend/src/routes/validationRoutes.js` (NEW)

### Frontend Files:
- `axiom/lib/services/validation_service.dart` (NEW)
- `axiom/lib/services/FormHandler.dart` (MODIFY)
- `axiom/lib/widgets/smart_text_field.dart` (NEW)

---

## 🚀 **Step 1: Backend Validation Service**

### Create AI Validation Service
```javascript
// axiomBackend/src/services/validationService.js
import openaiClient from './openaiClient.js';

class ValidationService {
  async validateField(fieldName, value, fieldType, context = {}) {
    const prompt = `
You are a form validation expert. Validate this field data and provide helpful feedback.

Field Details:
- Name: "${fieldName}"
- Value: "${value}"
- Type: "${fieldType}"
- Context: ${JSON.stringify(context)}

Return a JSON object with:
{
  "isValid": true/false,
  "errorMessage": "User-friendly error message or null",
  "suggestions": ["Suggestion 1", "Suggestion 2"],
  "confidence": 0.0-1.0
}

Validation rules to consider:
- Email: proper format, domain validity
- Phone: format, country codes
- Name: reasonable length, characters
- Address: completeness, format
- Numbers: range, format
- Dates: validity, format
- Business logic based on field name and context

Only return valid JSON, no explanations.
`;

    try {
      const response = await openaiClient.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.2,
      });

      const content = response.choices[0].message.content;
      return JSON.parse(content);
    } catch (error) {
      console.error('Validation AI Error:', error);
      // Fallback to basic validation
      return this.basicValidation(fieldName, value, fieldType);
    }
  }

  basicValidation(fieldName, value, fieldType) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.5
    };

    if (!value || value.trim() === '') {
      result.isValid = false;
      result.errorMessage = `${fieldName} is required`;
      return result;
    }

    // Basic type validation
    switch (fieldType.toLowerCase()) {
      case 'email':
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
          result.isValid = false;
          result.errorMessage = 'Please enter a valid email address';
          result.suggestions = ['Check for typos', 'Ensure domain is correct'];
        }
        break;
      
      case 'phone':
        const phoneRegex = /^[\d\s\-\+\(\)]+$/;
        if (!phoneRegex.test(value) || value.length < 10) {
          result.isValid = false;
          result.errorMessage = 'Please enter a valid phone number';
          result.suggestions = ['Include country code', 'Use format: +1234567890'];
        }
        break;
      
      case 'name':
        if (value.length < 2) {
          result.isValid = false;
          result.errorMessage = 'Name must be at least 2 characters';
        }
        break;
    }

    return result;
  }

  async validateForm(formData, formContext) {
    const validationResults = {};
    const overallErrors = [];

    for (const [fieldName, fieldValue] of Object.entries(formData)) {
      const fieldType = this.inferFieldType(fieldName, formContext);
      const validation = await this.validateField(fieldName, fieldValue, fieldType, formContext);
      
      validationResults[fieldName] = validation;
      
      if (!validation.isValid) {
        overallErrors.push({
          field: fieldName,
          message: validation.errorMessage,
          suggestions: validation.suggestions
        });
      }
    }

    return {
      isValid: overallErrors.length === 0,
      errors: overallErrors,
      fieldResults: validationResults,
      confidence: this.calculateOverallConfidence(validationResults)
    };
  }

  inferFieldType(fieldName, context) {
    const name = fieldName.toLowerCase();
    
    // Check explicit type definition
    if (context.fieldTypes && context.fieldTypes[fieldName]) {
      return context.fieldTypes[fieldName];
    }
    
    // Infer from field name
    if (name.includes('email')) return 'email';
    if (name.includes('phone') || name.includes('mobile')) return 'phone';
    if (name.includes('name') || name.includes('title')) return 'name';
    if (name.includes('password') || name.includes('pass')) return 'password';
    if (name.includes('date') || name.includes('time')) return 'date';
    if (name.includes('price') || name.includes('amount') || name.includes('cost')) return 'number';
    
    return 'text';
  }

  calculateOverallConfidence(fieldResults) {
    const confidences = Object.values(fieldResults).map(r => r.confidence);
    return confidences.reduce((sum, conf) => sum + conf, 0) / confidences.length;
  }

  async getFormImprovements(formData, validationResults) {
    const prompt = `
Analyze this form data and validation results to suggest improvements:

Form Data: ${JSON.stringify(formData)}
Validation Results: ${JSON.stringify(validationResults)}

Suggest improvements for:
1. User experience
2. Data quality
3. Error prevention
4. Field organization

Return suggestions as a JSON array of objects:
{
  "type": "ux|data|validation|layout",
  "priority": "high|medium|low",
  "suggestion": "Specific improvement suggestion",
  "field": "related_field_name_or_null"
}
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
      console.error('Form improvements AI Error:', error);
      return [];
    }
  }
}

export default new ValidationService();
```

### Create Validation Routes
```javascript
// axiomBackend/src/routes/validationRoutes.js
import { Router } from 'express';
import validationService from '../services/validationService.js';

const router = Router();

// Validate single field
router.post('/validate-field', async (req, res) => {
  try {
    const { fieldName, value, fieldType, context } = req.body;
    
    if (!fieldName || value === undefined) {
      return res.status(400).json({ 
        error: 'Field name and value are required' 
      });
    }

    const result = await validationService.validateField(
      fieldName, 
      value, 
      fieldType || 'text', 
      context || {}
    );
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Field Validation Error:', error);
    res.status(500).json({ 
      error: 'Validation failed',
      message: error.message 
    });
  }
});

// Validate entire form
router.post('/validate-form', async (req, res) => {
  try {
    const { formData, formContext } = req.body;
    
    if (!formData) {
      return res.status(400).json({ 
        error: 'Form data is required' 
      });
    }

    const result = await validationService.validateForm(formData, formContext || {});
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Form Validation Error:', error);
    res.status(500).json({ 
      error: 'Form validation failed',
      message: error.message 
    });
  }
});

// Get form improvement suggestions
router.post('/improvements', async (req, res) => {
  try {
    const { formData, validationResults } = req.body;
    
    if (!formData) {
      return res.status(400).json({ 
        error: 'Form data is required' 
      });
    }

    const suggestions = await validationService.getFormImprovements(
      formData, 
      validationResults || {}
    );
    
    res.json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    console.error('Improvements Error:', error);
    res.status(500).json({ 
      error: 'Failed to get improvements',
      message: error.message 
    });
  }
});

export default router;
```

### Update Server to Include Validation Routes
```javascript
// In axiomBackend/src/server.js, add:
import validationRoutes from './routes/validationRoutes.js';

// Add this line with other routes:
app.use('/api/validation', validationRoutes);
```

---

## 📱 **Step 2: Frontend Validation Service**

### Create Validation Service for Flutter
```dart
// axiom/lib/services/validation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ValidationService {
  static const String baseUrl = 'http://localhost:5000/api/validation';

  static Future<ValidationResult> validateField({
    required String fieldName,
    required String value,
    String? fieldType,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-field'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fieldName': fieldName,
          'value': value,
          'fieldType': fieldType ?? 'text',
          'context': context ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return ValidationResult.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Validation failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Validation Service Error: $e');
    }
  }

  static Future<FormValidationResult> validateForm({
    required Map<String, dynamic> formData,
    Map<String, dynamic>? formContext,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-form'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'formData': formData,
          'formContext': formContext ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return FormValidationResult.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Form validation failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Validation Service Error: $e');
    }
  }

  static Future<List<FormImprovement>> getImprovements({
    required Map<String, dynamic> formData,
    Map<String, dynamic>? validationResults,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/improvements'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'formData': formData,
          'validationResults': validationResults ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((item) => FormImprovement.fromJson(item))
              .toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to get improvements');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Validation Service Error: $e');
    }
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> suggestions;
  final double confidence;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.suggestions = const [],
    required this.confidence,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    return ValidationResult(
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
      suggestions: List<String>.from(json['suggestions'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class FormValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  final Map<String, ValidationResult> fieldResults;
  final double confidence;

  FormValidationResult({
    required this.isValid,
    this.errors = const [],
    required this.fieldResults,
    required this.confidence,
  });

  factory FormValidationResult.fromJson(Map<String, dynamic> json) {
    return FormValidationResult(
      isValid: json['isValid'] ?? false,
      errors: (json['errors'] as List?)
          ?.map((e) => ValidationError.fromJson(e))
          .toList() ?? [],
      fieldResults: (json['fieldResults'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, ValidationResult.fromJson(value)),
      ) ?? {},
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class ValidationError {
  final String field;
  final String message;
  final List<String> suggestions;

  ValidationError({
    required this.field,
    required this.message,
    this.suggestions = const [],
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

class FormImprovement {
  final String type;
  final String priority;
  final String suggestion;
  final String? field;

  FormImprovement({
    required this.type,
    required this.priority,
    required this.suggestion,
    this.field,
  });

  factory FormImprovement.fromJson(Map<String, dynamic> json) {
    return FormImprovement(
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'low',
      suggestion: json['suggestion'] ?? '',
      field: json['field'],
    );
  }
}
```

---

## 🎨 **Step 3: Smart Text Field Widget**

### Create Enhanced Text Field with AI Validation
```dart
// axiom/lib/widgets/smart_text_field.dart
import 'package:flutter/material.dart';
import 'package:axiom/services/validation_service.dart';
import 'package:axiom/models/widget_model.dart';

class SmartTextField extends StatefulWidget {
  final WidgetModel widgetModel;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(bool)? onValidationChanged;

  const SmartTextField({
    super.key,
    required this.widgetModel,
    required this.controller,
    this.onChanged,
    this.onValidationChanged,
  });

  @override
  State<SmartTextField> createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField> {
  bool _isValidating = false;
  ValidationResult? _lastValidation;
  String? _currentError;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    widget.onChanged?.call(text);
    
    // Debounce validation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && widget.controller.text == text) {
        _validateField(text);
      }
    });
  }

  Future<void> _validateField(String value) async {
    if (value.isEmpty) {
      setState(() {
        _currentError = null;
        _suggestions = [];
        _lastValidation = null;
      });
      widget.onValidationChanged?.call(true);
      return;
    }

    setState(() => _isValidating = true);

    try {
      final fieldName = widget.widgetModel.properties['label'] ?? 'Field';
      final fieldType = widget.widgetModel.properties['fieldType'] ?? 'text';
      
      final validation = await ValidationService.validateField(
        fieldName: fieldName,
        value: value,
        fieldType: fieldType,
        context: {
          'formType': widget.widgetModel.properties['formType'],
          'required': widget.widgetModel.properties['required'] ?? false,
        },
      );

      setState(() {
        _isValidating = false;
        _lastValidation = validation;
        _currentError = validation.isValid ? null : validation.errorMessage;
        _suggestions = validation.suggestions;
      });

      widget.onValidationChanged?.call(validation.isValid);
    } catch (e) {
      setState(() {
        _isValidating = false;
        _currentError = 'Validation error occurred';
        _suggestions = [];
      });
      widget.onValidationChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Field
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.widgetModel.properties['label'],
            hintText: widget.widgetModel.properties['hint'],
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _getBorderColor(),
                width: 2,
              ),
            ),
            errorText: _currentError,
            suffixIcon: _buildSuffixIcon(),
            helperText: _buildHelperText(),
          ),
          keyboardType: _getKeyboardType(),
          obscureText: widget.widgetModel.properties['obscure'] ?? false,
          maxLength: widget.widgetModel.properties['maxLength'],
        ),

        // Suggestions
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Suggestions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ..._suggestions.map((suggestion) => Padding(
                  padding: const EdgeInsets.only(left: 20, top: 2),
                  child: Text(
                    '• $suggestion',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getBorderColor() {
    if (_isValidating) return Colors.orange;
    if (_currentError != null) return Colors.red;
    if (_lastValidation != null && _lastValidation!.isValid) return Colors.green;
    return Colors.grey;
  }

  Widget? _buildSuffixIcon() {
    if (_isValidating) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    
    if (_lastValidation != null) {
      return Icon(
        _lastValidation!.isValid ? Icons.check_circle : Icons.error,
        color: _lastValidation!.isValid ? Colors.green : Colors.red,
      );
    }
    
    return null;
  }

  String? _buildHelperText() {
    if (_lastValidation != null) {
      return 'Confidence: ${(_lastValidation!.confidence * 100).toStringAsFixed(0)}%';
    }
    return null;
  }

  TextInputType _getKeyboardType() {
    final fieldType = widget.widgetModel.properties['fieldType'] ?? 'text';
    
    switch (fieldType.toLowerCase()) {
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'number':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }
}
```

---

## 🔧 **Step 4: Update FormHandler**

### Enhance FormHandler with Smart Validation
```dart
// In axiom/lib/services/FormHandler.dart, add these methods:

class FormHandler {
  // ... existing code ...

  static Map<String, ValidationResult> _validationResults = {};
  static bool _isFormValid = true;

  // Smart form validation
  static Future<FormValidationResult> validateFormSmartly(
    List<WidgetModel> widgets,
    Map<String, dynamic> formData,
  ) async {
    try {
      final formContext = {
        'fieldTypes': _extractFieldTypes(widgets),
        'requiredFields': _extractRequiredFields(widgets),
      };

      final result = await ValidationService.validateForm(
        formData: formData,
        formContext: formContext,
      );

      // Update validation results
      _validationResults = result.fieldResults;
      _isFormValid = result.isValid;

      return result;
    } catch (e) {
      print('Smart validation error: $e');
      // Fallback to basic validation
      return _fallbackValidation(widgets, formData);
    }
  }

  static Map<String, String> _extractFieldTypes(List<WidgetModel> widgets) {
    final fieldTypes = <String, String>{};
    
    for (var widget in widgets) {
      if (widget.type == 'TextField') {
        final fieldKey = widget.properties['fieldKey'] ?? widget.id;
        final fieldType = widget.properties['fieldType'] ?? 'text';
        fieldTypes[fieldKey] = fieldType;
      }
    }
    
    return fieldTypes;
  }

  static List<String> _extractRequiredFields(List<WidgetModel> widgets) {
    final requiredFields = <String>[];
    
    for (var widget in widgets) {
      if (widget.type == 'TextField') {
        final fieldKey = widget.properties['fieldKey'] ?? widget.id;
        final isRequired = widget.properties['required'] ?? false;
        if (isRequired) {
          requiredFields.add(fieldKey);
        }
      }
    }
    
    return requiredFields;
  }

  static FormValidationResult _fallbackValidation(
    List<WidgetModel> widgets,
    Map<String, dynamic> formData,
  ) {
    final errors = <ValidationError>[];
    final fieldResults = <String, ValidationResult>{};

    for (var widget in widgets) {
      if (widget.type == 'TextField') {
        final fieldKey = widget.properties['fieldKey'] ?? widget.id;
        final value = formData[fieldKey] ?? '';
        final isRequired = widget.properties['required'] ?? false;

        final validation = ValidationResult(
          isValid: !isRequired || value.isNotEmpty,
          errorMessage: isRequired && value.isEmpty ? 'This field is required' : null,
          suggestions: [],
          confidence: 0.5,
        );

        fieldResults[fieldKey] = validation;
        
        if (!validation.isValid) {
          errors.add(ValidationError(
            field: fieldKey,
            message: validation.errorMessage!,
            suggestions: [],
          ));
        }
      }
    }

    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      fieldResults: fieldResults,
      confidence: 0.5,
    );
  }

  // Get validation result for a specific field
  static ValidationResult? getFieldValidation(String fieldKey) {
    return _validationResults[fieldKey];
  }

  // Check if entire form is valid
  static bool get isFormValid => _isFormValid;

  // Get form improvement suggestions
  static Future<List<FormImprovement>> getFormImprovements(
    List<WidgetModel> widgets,
    Map<String, dynamic> formData,
  ) async {
    try {
      final validationResults = await validateFormSmartly(widgets, formData);
      
      return await ValidationService.getImprovements(
        formData: formData,
        validationResults: validationResults.fieldResults,
      );
    } catch (e) {
      print('Error getting improvements: $e');
      return [];
    }
  }
}
```

---

## 🧪 **Step 5: Testing**

### Test Smart Validation:

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

3. **Test Field Validation**
   - Create a form with email, phone, and name fields
   - Type invalid email: "test@" → Should show AI suggestions
   - Type invalid phone: "123" → Should get format suggestions
   - Type valid data → Should show green checkmark

4. **Test Form Validation**
   - Submit form with multiple errors
   - Check if all errors are displayed
   - Verify confidence scores

5. **Test Improvement Suggestions**
   - Fill a form partially
   - Request improvements
   - Check if suggestions are helpful

### Test Cases to Try:
- **Email**: "test@", "test@.com", "valid.email@example.com"
- **Phone**: "123", "123-456-7890", "+1-123-456-7890"
- **Name**: "A", "John Doe", "123"
- **Business Context**: Order form with quantity, price fields

---

## 🐛 **Common Issues & Solutions**

### Issue 1: Validation Too Slow
**Solution**: Increase debounce time or use basic validation for typing

### Issue 2: AI Returns Invalid JSON
**Solution**: Backend has fallback validation built-in

### Issue 3: Too Many API Calls
**Solution**: Implement caching for repeated validations

### Issue 4: Suggestions Not Helpful
**Solution**: Adjust the AI prompt for better context awareness

---

## ✅ **Success Criteria**

- [ ] Fields validate in real-time with AI
- [ ] Helpful error messages and suggestions appear
- [ ] Form validation works for multiple fields
- [ ] Confidence scores are displayed
- [ ] Fallback validation works when AI fails
- [ ] Performance is acceptable for real-time validation

---

## 🎉 **Next Steps**

Once this feature is working, proceed to **Feature #3: AI Widget Suggestions** by opening `guides/03_ai_widget_suggestions.md`.

**Great! You've added AI-powered smart validation to your forms!** 🧠✨
