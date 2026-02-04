class ValidationService {
  async validateField(fieldName, value, fieldType, context = {}) {
    console.log('🧠 Validating field:', fieldName, 'Value:', value, 'Type:', fieldType);
    
    // Simulate AI processing time
    await new Promise(resolve => setTimeout(resolve, 300));
    
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    // Basic empty check
    if (!value || value.trim() === '') {
      const isRequired = context.required || false;
      if (isRequired) {
        result.isValid = false;
        result.errorMessage = `${fieldName} is required`;
        result.suggestions = [`Please enter a valid ${fieldName.toLowerCase()}`];
        result.confidence = 0.9;
      }
      return result;
    }

    // Smart validation based on field type
    switch (fieldType?.toLowerCase()) {
      case 'email':
        return this.validateEmail(value, fieldName);
      case 'phone':
      case 'mobile':
      case 'telephone':
        return this.validatePhone(value, fieldName);
      case 'password':
        return this.validatePassword(value, fieldName, context);
      case 'name':
      case 'username':
      case 'fullname':
        return this.validateName(value, fieldName);
      case 'number':
      case 'integer':
        return this.validateNumber(value, fieldName, context);
      case 'date':
        return this.validateDate(value, fieldName);
      case 'url':
        return this.validateURL(value, fieldName);
      default:
        return this.validateText(value, fieldName, context);
    }
  }

  validateEmail(value, fieldName) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    
    if (!emailRegex.test(value)) {
      result.isValid = false;
      result.errorMessage = 'Please enter a valid email address';
      result.suggestions = [
        'Check for typos in the email address',
        'Ensure domain is correct (e.g., gmail.com, yahoo.com)',
        'Email format: user@domain.com'
      ];
      result.confidence = 0.9;
    }

    // Additional smart checks
    if (value.length < 5) {
      result.suggestions.push('Email seems too short');
    }
    
    if (!value.includes('.')) {
      result.suggestions.push('Email must include a domain extension (.com, .org, etc.)');
    }

    return result;
  }

  validatePhone(value, fieldName) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    // Remove common formatting
    const cleanPhone = value.replace(/[\s\-\(\)]/g, '');
    const phoneRegex = /^[\d\+]+$/;
    
    if (!phoneRegex.test(cleanPhone)) {
      result.isValid = false;
      result.errorMessage = 'Please enter a valid phone number';
      result.suggestions = [
        'Use only numbers and optional + for country code',
        'Format: +1234567890 or 1234567890',
        'Remove any letters or special characters'
      ];
      result.confidence = 0.9;
      return result;
    }

    if (cleanPhone.length < 10) {
      result.isValid = false;
      result.errorMessage = 'Phone number is too short';
      result.suggestions = [
        'Include area code',
        'Use country code for international numbers',
        'Minimum 10 digits recommended'
      ];
      result.confidence = 0.8;
    } else if (cleanPhone.length > 15) {
      result.suggestions.push('Phone number seems unusually long');
    }

    return result;
  }

  validatePassword(value, fieldName, context) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    if (value.length < 8) {
      result.isValid = false;
      result.errorMessage = 'Password must be at least 8 characters';
      result.suggestions = [
        'Use at least 8 characters',
        'Include uppercase and lowercase letters',
        'Add numbers and special characters (!@#$%^&*)'
      ];
      result.confidence = 0.9;
      return result;
    }

    // Smart password strength analysis
    const suggestions = [];
    
    if (!/[A-Z]/.test(value)) {
      suggestions.push('Add uppercase letter for stronger password');
    }
    if (!/[a-z]/.test(value)) {
      suggestions.push('Add lowercase letter');
    }
    if (!/\d/.test(value)) {
      suggestions.push('Include numbers for better security');
    }
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(value)) {
      suggestions.push('Add special characters (!@#$%^&*)');
    }

    if (suggestions.length > 0) {
      result.suggestions = suggestions;
      result.confidence = 0.7;
    }

    // Check for common weak passwords
    const commonPasswords = ['password', '12345678', 'qwerty', 'admin', 'letmein'];
    if (commonPasswords.some(pass => value.toLowerCase().includes(pass))) {
      result.isValid = false;
      result.errorMessage = 'Password is too common';
      result.suggestions = ['Choose a more unique password', 'Avoid common patterns'];
      result.confidence = 0.95;
    }

    return result;
  }

  validateName(value, fieldName) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    if (value.length < 2) {
      result.isValid = false;
      result.errorMessage = 'Name must be at least 2 characters';
      result.suggestions = ['Enter a full name', 'Minimum 2 characters required'];
      result.confidence = 0.9;
      return result;
    }

    if (value.length > 50) {
      result.suggestions.push('Name seems unusually long');
    }

    // Check for valid characters
    const nameRegex = /^[a-zA-Z\s\-'\.]+$/;
    if (!nameRegex.test(value)) {
      result.isValid = false;
      result.errorMessage = 'Name contains invalid characters';
      result.suggestions = [
        'Use only letters, spaces, hyphens, and apostrophes',
        'Remove numbers and special characters'
      ];
      result.confidence = 0.9;
    }

    // Smart name format suggestions
    if (!value.includes(' ') && value.length > 3) {
      result.suggestions.push('Consider including last name');
    }

    return result;
  }

  validateNumber(value, fieldName, context) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    const num = parseFloat(value);
    
    if (isNaN(num)) {
      result.isValid = false;
      result.errorMessage = 'Please enter a valid number';
      result.suggestions = ['Use only digits and decimal point', 'Remove any text characters'];
      result.confidence = 0.9;
      return result;
    }

    // Context-aware validation
    if (context.minValue !== undefined && num < context.minValue) {
      result.isValid = false;
      result.errorMessage = `Value must be at least ${context.minValue}`;
      result.suggestions = [`Enter a number >= ${context.minValue}`];
      result.confidence = 0.9;
    }

    if (context.maxValue !== undefined && num > context.maxValue) {
      result.isValid = false;
      result.errorMessage = `Value must be no more than ${context.maxValue}`;
      result.suggestions = [`Enter a number <= ${context.maxValue}`];
      result.confidence = 0.9;
    }

    // Smart suggestions based on field name
    const fieldNameLower = fieldName.toLowerCase();
    if (fieldNameLower.includes('age') && (num < 1 || num > 120)) {
      result.suggestions.push('Age should be between 1 and 120');
    }
    
    if (fieldNameLower.includes('rating') && (num < 0 || num > 5)) {
      result.suggestions.push('Rating should be between 0 and 5');
    }

    return result;
  }

  validateDate(value, fieldName) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    const date = new Date(value);
    
    if (isNaN(date.getTime())) {
      result.isValid = false;
      result.errorMessage = 'Please enter a valid date';
      result.suggestions = [
        'Use format: MM/DD/YYYY or YYYY-MM-DD',
        'Ensure month, day, and year are valid'
      ];
      result.confidence = 0.9;
      return result;
    }

    // Check for reasonable dates
    const now = new Date();
    if (date > now) {
      result.suggestions.push('Date is in the future');
    }

    if (date.getFullYear() < 1900) {
      result.suggestions.push('Date seems too far in the past');
    }

    return result;
  }

  validateURL(value, fieldName) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.8
    };

    try {
      new URL(value);
    } catch (error) {
      result.isValid = false;
      result.errorMessage = 'Please enter a valid URL';
      result.suggestions = [
        'Include http:// or https://',
        'Format: https://example.com',
        'Ensure domain name is valid'
      ];
      result.confidence = 0.9;
    }

    return result;
  }

  validateText(value, fieldName, context) {
    const result = {
      isValid: true,
      errorMessage: null,
      suggestions: [],
      confidence: 0.7
    };

    // Context-aware text validation
    const fieldNameLower = fieldName.toLowerCase();
    
    if (fieldNameLower.includes('description') && value.length < 10) {
      result.suggestions.push('Description could be more detailed');
    }

    if (fieldNameLower.includes('title') && value.length > 100) {
      result.suggestions.push('Title might be too long for optimal display');
    }

    if (context.minLength && value.length < context.minLength) {
      result.isValid = false;
      result.errorMessage = `Must be at least ${context.minLength} characters`;
      result.suggestions = [`Add ${context.minLength - value.length} more characters`];
      result.confidence = 0.9;
    }

    if (context.maxLength && value.length > context.maxLength) {
      result.isValid = false;
      result.errorMessage = `Must be no more than ${context.maxLength} characters`;
      result.suggestions = [`Remove ${value.length - context.maxLength} characters`];
      result.confidence = 0.9;
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
    if (name.includes('password') || name.includes('pass')) return 'password';
    if (name.includes('name') || name.includes('title')) return 'name';
    if (name.includes('date') || name.includes('time')) return 'date';
    if (name.includes('price') || name.includes('amount') || name.includes('cost')) return 'number';
    if (name.includes('url') || name.includes('link')) return 'url';
    
    return 'text';
  }

  calculateOverallConfidence(fieldResults) {
    const confidences = Object.values(fieldResults).map(r => r.confidence);
    return confidences.reduce((sum, conf) => sum + conf, 0) / confidences.length;
  }
}

export default new ValidationService();
