import 'dart:async';

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
  Timer? _validationTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _validationTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    widget.onChanged?.call(text);
    
    // Debounce validation (wait 500ms after user stops typing)
    _validationTimer?.cancel();
    _validationTimer = Timer(const Duration(milliseconds: 500), () {
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
          'required': widget.widgetModel.properties['required'] ?? false,
          'minLength': widget.widgetModel.properties['minLength'],
          'maxLength': widget.widgetModel.properties['maxLength'],
          'minValue': widget.widgetModel.properties['minValue'],
          'maxValue': widget.widgetModel.properties['maxValue'],
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
      case 'mobile':
        return TextInputType.phone;
      case 'number':
      case 'integer':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }
}
