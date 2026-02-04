class MockAIService {
  async generateAPIConfig(description) {
    console.log('🤖 Smart Mock AI Generating API config for:', description);
    
    // Simulate AI processing time
    await new Promise(resolve => setTimeout(resolve, 800));
    
    // Enhanced pattern recognition
    const mockConfig = {
      name: this.extractName(description),
      method: this.extractMethod(description),
      path: this.extractPath(description),
      purpose: this.extractPurpose(description),
      collection: this.extractCollection(description),
      fields: this.extractFields(description),
      auth: this.shouldRequireAuth(description)
    };
    
    return mockConfig;
  }

  extractName(description) {
    const desc = description.toLowerCase();
    
    // More sophisticated name extraction
    if (desc.includes('customer') && desc.includes('order')) return 'Customer Order API';
    if (desc.includes('user') && desc.includes('registration')) return 'User Registration API';
    if (desc.includes('user') && desc.includes('login')) return 'User Login API';
    if (desc.includes('feedback') || desc.includes('review')) return 'Feedback API';
    if (desc.includes('product') && desc.includes('catalog')) return 'Product Catalog API';
    if (desc.includes('contact') && desc.includes('form')) return 'Contact Form API';
    if (desc.includes('survey') || desc.includes('poll')) return 'Survey API';
    if (desc.includes('comment') && desc.includes('system')) return 'Comment System API';
    if (desc.includes('search') && desc.includes('functionality')) return 'Search API';
    if (desc.includes('notification') || desc.includes('alert')) return 'Notification API';
    
    // Fallback patterns
    if (desc.includes('user')) return 'User Management API';
    if (desc.includes('product')) return 'Product API';
    if (desc.includes('order')) return 'Order API';
    if (desc.includes('payment')) return 'Payment API';
    if (desc.includes('inventory')) return 'Inventory API';
    
    return 'Generated API';
  }

  extractMethod(description) {
    const desc = description.toLowerCase();
    
    // More sophisticated method detection
    if (desc.includes('get') || desc.includes('fetch') || desc.includes('retrieve') || desc.includes('list') || desc.includes('show') || desc.includes('display')) {
      return 'GET';
    }
    if (desc.includes('update') || desc.includes('edit') || desc.includes('modify') || desc.includes('change')) {
      return 'PUT';
    }
    if (desc.includes('delete') || desc.includes('remove') || desc.includes('destroy') || desc.includes('eliminate')) {
      return 'DELETE';
    }
    if (desc.includes('login') || desc.includes('authenticate')) {
      return 'POST'; // Login is always POST
    }
    
    // Default to POST for creation
    return 'POST';
  }

  extractPath(description) {
    const desc = description.toLowerCase();
    
    // More specific path generation
    if (desc.includes('user') && desc.includes('registration')) return '/api/auth/register';
    if (desc.includes('user') && desc.includes('login')) return '/api/auth/login';
    if (desc.includes('customer') && desc.includes('order')) return '/api/orders';
    if (desc.includes('feedback') || desc.includes('review')) return '/api/feedback';
    if (desc.includes('product') && desc.includes('catalog')) return '/api/products';
    if (desc.includes('contact') && desc.includes('form')) return '/api/contact';
    if (desc.includes('survey') || desc.includes('poll')) return '/api/surveys';
    if (desc.includes('comment')) return '/api/comments';
    if (desc.includes('search')) return '/api/search';
    if (desc.includes('notification')) return '/api/notifications';
    
    // Fallback paths
    if (desc.includes('user')) return '/api/users';
    if (desc.includes('product')) return '/api/products';
    if (desc.includes('order')) return '/api/orders';
    if (desc.includes('payment')) return '/api/payments';
    if (desc.includes('inventory')) return '/api/inventory';
    
    return '/api/generated';
  }

  extractPurpose(description) {
    const desc = description.toLowerCase();
    
    if (desc.includes('get') || desc.includes('fetch') || desc.includes('retrieve') || desc.includes('list')) return 'list';
    if (desc.includes('update') || desc.includes('edit') || desc.includes('modify')) return 'update';
    if (desc.includes('delete') || desc.includes('remove')) return 'delete';
    if (desc.includes('login') || desc.includes('authenticate')) return 'login';
    if (desc.includes('register') || desc.includes('signup')) return 'register';
    
    return 'create';
  }

  extractCollection(description) {
    const desc = description.toLowerCase();
    
    // Collection name mapping
    if (desc.includes('user') && desc.includes('registration')) return 'users';
    if (desc.includes('customer') && desc.includes('order')) return 'orders';
    if (desc.includes('feedback') || desc.includes('review')) return 'feedback';
    if (desc.includes('product')) return 'products';
    if (desc.includes('contact')) return 'contacts';
    if (desc.includes('survey') || desc.includes('poll')) return 'surveys';
    if (desc.includes('comment')) return 'comments';
    if (desc.includes('notification')) return 'notifications';
    
    // Fallback collections
    if (desc.includes('user')) return 'users';
    if (desc.includes('order')) return 'orders';
    if (desc.includes('payment')) return 'payments';
    if (desc.includes('inventory')) return 'inventory';
    
    return 'generated_data';
  }

  extractFields(description) {
    const desc = description.toLowerCase();
    const fields = [];
    
    // Enhanced field extraction with more patterns
    const fieldPatterns = [
      { keywords: ['name', 'username', 'fullname'], type: 'string', required: true, desc: 'Name field' },
      { keywords: ['email'], type: 'email', required: true, desc: 'Email address' },
      { keywords: ['password', 'pass'], type: 'password', required: true, desc: 'Password' },
      { keywords: ['phone', 'mobile', 'telephone'], type: 'phone', required: false, desc: 'Phone number' },
      { keywords: ['address'], type: 'string', required: false, desc: 'Address' },
      { keywords: ['rating', 'score'], type: 'number', required: false, desc: 'Rating value' },
      { keywords: ['comment', 'comments', 'feedback', 'review', 'message'], type: 'string', required: false, desc: 'Comments/Feedback' },
      { keywords: ['price', 'cost', 'amount'], type: 'number', required: true, desc: 'Price' },
      { keywords: ['quantity', 'qty'], type: 'number', required: true, desc: 'Quantity' },
      { keywords: ['title', 'subject'], type: 'string', required: true, desc: 'Title' },
      { keywords: ['description', 'desc'], type: 'string', required: false, desc: 'Description' },
      { keywords: ['category', 'type'], type: 'string', required: true, desc: 'Category' },
      { keywords: ['status'], type: 'string', required: false, desc: 'Status' },
      { keywords: ['date', 'created', 'updated'], type: 'date', required: false, desc: 'Date' },
      { keywords: ['id'], type: 'string', required: true, desc: 'ID' },
      { keywords: ['image', 'photo', 'picture'], type: 'string', required: false, desc: 'Image URL' },
      { keywords: ['url', 'link'], type: 'string', required: false, desc: 'URL' },
      { keywords: ['active', 'enabled'], type: 'boolean', required: false, desc: 'Active status' },
      { keywords: ['priority'], type: 'number', required: false, desc: 'Priority level' }
    ];

    fieldPatterns.forEach(pattern => {
      if (pattern.keywords.some(keyword => desc.includes(keyword))) {
        // Avoid duplicate fields
        if (!fields.find(f => f.name === pattern.keywords[0])) {
          fields.push({
            name: pattern.keywords[0],
            type: pattern.type,
            required: pattern.required,
            description: pattern.desc
          });
        }
      }
    });

    return fields;
  }

  shouldRequireAuth(description) {
    const desc = description.toLowerCase();
    
    // APIs that typically require authentication
    const authRequiredPatterns = [
      'user', 'profile', 'account', 'order', 'payment', 
      'private', 'secure', 'admin', 'dashboard'
    ];
    
    return authRequiredPatterns.some(pattern => desc.includes(pattern));
  }

  async suggestAPIImprovements(existingConfig) {
    // Smart suggestions based on API configuration
    const suggestions = [];
    
    // Security suggestions
    if (!existingConfig.auth) {
      suggestions.push('Add authentication to secure this endpoint');
    }
    
    // Validation suggestions
    if (existingConfig.fields && existingConfig.fields.length > 0) {
      suggestions.push('Add input validation for all fields');
      suggestions.push('Implement rate limiting to prevent abuse');
    }
    
    // Performance suggestions
    suggestions.push('Add proper error handling and logging');
    suggestions.push('Consider adding pagination for list endpoints');
    
    // Documentation suggestions
    suggestions.push('Add API documentation for better developer experience');
    
    // Data integrity suggestions
    if (existingConfig.method === 'POST' || existingConfig.method === 'PUT') {
      suggestions.push('Add data sanitization to prevent injection attacks');
    }
    
    return suggestions;
  }
}

export default new MockAIService();
