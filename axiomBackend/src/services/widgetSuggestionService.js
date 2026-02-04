class WidgetSuggestionService {
  async getWidgetSuggestions(projectContext, existingWidgets, userIntent = '') {
    console.log('🎯 Getting widget suggestions for:', userIntent);
    
    // Simulate AI processing time
    await new Promise(resolve => setTimeout(resolve, 600));
    
    // Enhanced pattern recognition for widget suggestions
    const suggestions = [];
    const layoutSuggestions = [];
    const nextSteps = [];
    
    // Analyze project context and existing widgets
    const existingTypes = existingWidgets.map(w => w.type.toLowerCase());
    const projectName = projectContext.name?.toLowerCase() || '';
    const projectDescription = projectContext.description?.toLowerCase() || '';
    const userIntentLower = userIntent.toLowerCase();
    
    // Generate widget suggestions based on context
    suggestions.push(...this.generateContextualWidgets(projectName, projectDescription, existingTypes, userIntentLower));
    
    // Generate layout suggestions
    layoutSuggestions.push(...this.generateLayoutSuggestions(existingTypes, projectName, projectDescription));
    
    // Generate next steps
    nextSteps.push(...this.generateNextSteps(existingTypes, projectName, projectDescription));
    
    return {
      suggestions,
      layoutSuggestions,
      nextSteps
    };
  }

  generateContextualWidgets(projectName, projectDescription, existingTypes, userIntent) {
    const suggestions = [];
    const intent = userIntent.toLowerCase();
    const combinedText = (projectName + ' ' + projectDescription + ' ' + userIntent).toLowerCase();
    
    // Enhanced NLP keyword matching with better pattern recognition
    const patterns = [
      // Contact & Communication
      {
        keywords: ['contact', 'form', 'message', 'email', 'name', 'phone'],
        widgets: [
          this.createSuggestion('TextField', 'Name input field', 'high', {
            label: 'Name',
            fieldType: 'text',
            required: true,
            hint: 'Enter full name'
          }),
          this.createSuggestion('TextField', 'Email input field', 'high', {
            label: 'Email',
            fieldType: 'email',
            required: true,
            hint: 'Enter email address'
          }),
          this.createSuggestion('TextField', 'Phone input field', 'medium', {
            label: 'Phone',
            fieldType: 'phone',
            required: false,
            hint: 'Enter phone number'
          }),
          this.createSuggestion('TextField', 'Message area', 'medium', {
            label: 'Message',
            fieldType: 'text',
            required: false,
            hint: 'Enter your message'
          }),
          this.createSuggestion('Button', 'Submit button', 'high', {
            label: 'Submit',
            text: 'Send Message'
          })
        ]
      },
      
      // User Authentication
      {
        keywords: ['login', 'signin', 'register', 'signup', 'auth', 'password', 'username'],
        widgets: [
          this.createSuggestion('TextField', 'Email/Username field', 'high', {
            label: 'Email',
            fieldType: 'email',
            required: true,
            hint: 'Enter email or username'
          }),
          this.createSuggestion('TextField', 'Password field', 'high', {
            label: 'Password',
            fieldType: 'password',
            required: true,
            hint: 'Enter password'
          }),
          this.createSuggestion('Button', 'Login/Register button', 'high', {
            label: 'Login',
            text: intent.includes('register') || intent.includes('signup') ? 'Sign Up' : 'Login'
          })
        ]
      },
      
      // Survey & Feedback
      {
        keywords: ['survey', 'feedback', 'review', 'rating', 'poll', 'question'],
        widgets: [
          this.createSuggestion('TextField', 'Survey question', 'high', {
            label: 'Question',
            fieldType: 'text',
            required: true,
            hint: 'Enter survey question'
          }),
          this.createSuggestion('Radio', 'Multiple choice options', 'medium', {
            label: 'Options',
            required: false
          }),
          this.createSuggestion('Checkbox', 'Check all that apply', 'medium', {
            label: 'Options',
            required: false
          }),
          this.createSuggestion('TextField', 'Rating field', 'medium', {
            label: 'Rating',
            fieldType: 'number',
            required: false,
            hint: 'Rate from 1-5'
          }),
          this.createSuggestion('TextField', 'Comments', 'medium', {
            label: 'Comments',
            fieldType: 'text',
            required: false,
            hint: 'Additional feedback'
          })
        ]
      },
      
      // E-commerce & Products
      {
        keywords: ['product', 'ecommerce', 'shop', 'store', 'buy', 'price', 'cart', 'catalog'],
        widgets: [
          this.createSuggestion('Image', 'Product image', 'high', {
            label: 'Product Image',
            hint: 'Product photo URL'
          }),
          this.createSuggestion('TextField', 'Product name', 'high', {
            label: 'Product Name',
            fieldType: 'text',
            required: true
          }),
          this.createSuggestion('TextField', 'Price', 'high', {
            label: 'Price',
            fieldType: 'number',
            required: true,
            hint: '0.00'
          }),
          this.createSuggestion('TextField', 'Description', 'medium', {
            label: 'Description',
            fieldType: 'text',
            required: false,
            hint: 'Product description'
          }),
          this.createSuggestion('TextField', 'Quantity', 'medium', {
            label: 'Quantity',
            fieldType: 'number',
            required: false,
            hint: '1'
          }),
          this.createSuggestion('Button', 'Add to Cart', 'high', {
            label: 'AddCart',
            text: 'Add to Cart'
          })
        ]
      },
      
      // Dashboard & Analytics
      {
        keywords: ['dashboard', 'analytics', 'stats', 'data', 'chart', 'graph', 'report'],
        widgets: [
          this.createSuggestion('Card', 'Stats card', 'high', {
            label: 'StatsCard',
            text: 'Total Users: 0'
          }),
          this.createSuggestion('ListView', 'Data list', 'medium', {
            label: 'DataList'
          }),
          this.createSuggestion('Text', 'Dashboard title', 'high', {
            label: 'DashboardTitle',
            text: 'Dashboard Overview'
          }),
          this.createSuggestion('Container', 'Chart container', 'medium', {
            label: 'ChartContainer'
          })
        ]
      },
      
      // Blog & Content
      {
        keywords: ['blog', 'post', 'article', 'content', 'news', 'story'],
        widgets: [
          this.createSuggestion('Text', 'Article title', 'high', {
            label: 'Title',
            text: 'Article Title'
          }),
          this.createSuggestion('Text', 'Article content', 'high', {
            label: 'Content',
            text: 'Article content goes here...'
          }),
          this.createSuggestion('Image', 'Article image', 'medium', {
            label: 'ArticleImage',
            hint: 'Image URL'
          }),
          this.createSuggestion('TextField', 'Author name', 'medium', {
            label: 'Author',
            fieldType: 'text',
            hint: 'Author name'
          }),
          this.createSuggestion('TextField', 'Publish date', 'medium', {
            label: 'Date',
            fieldType: 'date',
            hint: 'Publish date'
          })
        ]
      },
      
      // Social & Profile
      {
        keywords: ['social', 'profile', 'user', 'avatar', 'bio', 'about'],
        widgets: [
          this.createSuggestion('Image', 'Profile picture', 'high', {
            label: 'Avatar',
            hint: 'Profile picture URL'
          }),
          this.createSuggestion('Text', 'User name', 'high', {
            label: 'Username',
            text: '@username'
          }),
          this.createSuggestion('Text', 'Bio', 'medium', {
            label: 'Bio',
            text: 'User bio goes here...'
          }),
          this.createSuggestion('TextField', 'Location', 'medium', {
            label: 'Location',
            fieldType: 'text',
            hint: 'City, Country'
          }),
          this.createSuggestion('TextField', 'Website', 'low', {
            label: 'Website',
            fieldType: 'url',
            hint: 'https://example.com'
          })
        ]
      },
      
      // Search & Filter
      {
        keywords: ['search', 'filter', 'find', 'query', 'lookup'],
        widgets: [
          this.createSuggestion('TextField', 'Search box', 'high', {
            label: 'Search',
            fieldType: 'text',
            required: false,
            hint: 'Search...'
          }),
          this.createSuggestion('Button', 'Search button', 'high', {
            label: 'SearchBtn',
            text: 'Search'
          }),
          this.createSuggestion('Dropdown', 'Filter dropdown', 'medium', {
            label: 'Filter',
            required: false
          })
        ]
      },
      
      // Settings & Configuration
      {
        keywords: ['settings', 'config', 'options', 'preferences', 'setup'],
        widgets: [
          this.createSuggestion('TextField', 'Setting name', 'medium', {
            label: 'SettingName',
            fieldType: 'text',
            required: true
          }),
          this.createSuggestion('TextField', 'Setting value', 'medium', {
            label: 'SettingValue',
            fieldType: 'text',
            required: true
          }),
          this.createSuggestion('Checkbox', 'Enable/Disable', 'medium', {
            label: 'Enable',
            required: false
          }),
          this.createSuggestion('Button', 'Save settings', 'high', {
            label: 'Save',
            text: 'Save Settings'
          })
        ]
      },
      
      // Navigation & Menu
      {
        keywords: ['menu', 'nav', 'navigation', 'links', 'menuitem'],
        widgets: [
          this.createSuggestion('Text', 'Menu item', 'medium', {
            label: 'MenuItem',
            text: 'Menu Item'
          }),
          this.createSuggestion('Button', 'Navigation button', 'high', {
            label: 'NavButton',
            text: 'Home'
          }),
          this.createSuggestion('Container', 'Menu container', 'medium', {
            label: 'MenuContainer'
          })
        ]
      },
      
      // Forms & Input (General)
      {
        keywords: ['input', 'field', 'data', 'entry', 'form'],
        widgets: [
          this.createSuggestion('TextField', 'Text input', 'high', {
            label: 'Input',
            fieldType: 'text',
            required: false,
            hint: 'Enter text'
          }),
          this.createSuggestion('TextField', 'Number input', 'medium', {
            label: 'Number',
            fieldType: 'number',
            required: false,
            hint: 'Enter number'
          }),
          this.createSuggestion('Dropdown', 'Selection', 'medium', {
            label: 'Select',
            required: false
          }),
          this.createSuggestion('Button', 'Submit', 'high', {
            label: 'Submit',
            text: 'Submit'
          })
        ]
      }
    ];

    // Enhanced pattern matching with scoring
    let bestMatch = null;
    let bestScore = 0;

    for (let i = 0; i < patterns.length; i++) {
      const pattern = patterns[i];
      let score = 0;
      
      // Calculate match score
      for (let j = 0; j < pattern.keywords.length; j++) {
        const keyword = pattern.keywords[j];
        if (intent.includes(keyword)) score += 3; // User intent has highest weight
        if (combinedText.includes(keyword)) score += 1; // Combined text has lower weight
      }
      
      // Bonus for exact phrase matches
      for (let j = 0; j < pattern.keywords.length; j++) {
        const keyword = pattern.keywords[j];
        if (intent.includes(keyword)) score += 5;
      }
      
      if (score > bestScore) {
        bestScore = score;
        bestMatch = pattern;
      }
    }

    // If we found a good match, use those widgets
    if (bestMatch && bestScore >= 2) {
      suggestions.push(...bestMatch.widgets);
    } else {
      // Fallback: suggest basic form components for any input-related intent
      if (intent.length > 2) {
        suggestions.push(
          this.createSuggestion('TextField', 'Text input field', 'high', {
            label: 'Input',
            fieldType: 'text',
            required: false,
            hint: 'Enter text'
          }),
          this.createSuggestion('Button', 'Action button', 'high', {
            label: 'Action',
            text: 'Submit'
          })
        );
      }
    }
    
    // Always suggest missing essential widgets
    if (!existingTypes.includes('button')) {
      suggestions.push(
        this.createSuggestion('Button', 'Action button', 'high', {
          label: 'Submit',
          text: 'Submit'
        })
      );
    }
    
    if (!existingTypes.includes('label') && existingTypes.length > 0) {
      suggestions.push(
        this.createSuggestion('Label', 'Section title', 'medium', {
          text: 'Section Title'
        })
      );
    }
    
    // Remove duplicates and return
    const uniqueSuggestions = suggestions.filter((suggestion, index, self) => 
      index === self.findIndex((s) => s.widgetType === suggestion.widgetType)
    );
    
    return uniqueSuggestions;
  }

  generateLayoutSuggestions(existingTypes, projectName, projectDescription) {
    const suggestions = [];
    
    if (existingTypes.length === 0) {
      suggestions.push({
        type: 'single-column',
        description: 'Start with a simple single-column layout',
        widgets: []
      });
    } else if (existingTypes.length <= 3) {
      suggestions.push({
        type: 'single-column',
        description: 'Keep using single-column layout for simplicity',
        widgets: existingTypes
      });
    } else {
      suggestions.push({
        type: 'two-column',
        description: 'Consider two-column layout for better organization',
        widgets: ['TextField', 'Button']
      });
    }
    
    if (projectName.includes('dashboard') || projectDescription.includes('dashboard')) {
      suggestions.push({
        type: 'grid',
        description: 'Grid layout works well for dashboards',
        widgets: ['Card', 'ListView']
      });
    }
    
    return suggestions;
  }

  generateNextSteps(existingTypes, projectName, projectDescription) {
    const steps = [];
    
    if (existingTypes.length === 0) {
      steps.push('Add your first widget to get started');
      steps.push('Consider the user journey and flow');
    } else if (existingTypes.length < 3) {
      steps.push('Add more widgets to create a complete form');
      steps.push('Think about the user experience');
    } else {
      steps.push('Test your form with sample data');
      steps.push('Consider adding validation rules');
      steps.push('Optimize the layout for mobile devices');
    }
    
    if (!existingTypes.includes('button')) {
      steps.push('Add a submit button to enable form submission');
    }
    
    return steps;
  }

  createSuggestion(widgetType, reason, priority, properties = {}) {
    return {
      widgetType,
      reason,
      priority,
      properties: {
        label: properties['label'] || 'New ' + widgetType,
        hint: properties['hint'] || 'Enter ' + widgetType.toLowerCase() + ' information',
        fieldType: properties['fieldType'] || 'text',
        required: properties['required'] || false,
        text: properties['text'] || 'Button Text',
        ...properties
      },
      position: {
        suggestedX: 100 + Math.floor(Math.random() * 200),
        suggestedY: 100 + Math.floor(Math.random() * 200)
      }
    };
  }

  async getWidgetOptimization(widgets, projectContext) {
    console.log('🔧 Getting widget optimization suggestions');
    
    // Simulate AI processing time
    await new Promise(resolve => setTimeout(resolve, 800));
    
    const optimizations = [];
    
    // Analyze widgets for optimization opportunities
    widgets.forEach(widget => {
      if (widget.type === 'TextField') {
        const label = widget.properties?.label || '';
        const fieldType = widget.properties?.fieldType || 'text';
        
        // Field type optimization
        if (label.toLowerCase().includes('email') && fieldType !== 'email') {
          optimizations.push({
            widgetId: widget.id,
            type: 'field-type',
            suggestion: 'Change field type to "email" for better validation',
            priority: 'high',
            before: `Field "${label}" using generic text input`,
            after: `Field "${label}" using email validation with format checking`
          });
        }
        
        // Required field optimization
        if (label.toLowerCase().includes('name') && !widget.properties?.required) {
          optimizations.push({
            widgetId: widget.id,
            type: 'validation',
            suggestion: 'Mark name fields as required for better data quality',
            priority: 'medium',
            before: 'Name field is optional',
            after: 'Name field is required with validation'
          });
        }
      }
      
      if (widget.type === 'Button') {
        const text = widget.properties?.text || '';
        
        // Button text optimization
        if (text.length > 20) {
          optimizations.push({
            widgetId: widget.id,
            type: 'ux',
            suggestion: 'Shorten button text for better mobile experience',
            priority: 'medium',
            before: `Button text: "${text}"`,
            after: `Button text: "${text.substring(0, 20)}..."`
          });
        }
        
        // Button action optimization
        if (!widget.onClick && !widget.onSubmit) {
          optimizations.push({
            widgetId: widget.id,
            type: 'functionality',
            suggestion: 'Add click handler to make button functional',
            priority: 'high',
            before: 'Button has no action',
            after: 'Button triggers form submission or custom action'
          });
        }
      }
    });
    
    // General optimizations
    if (widgets.length > 10) {
      optimizations.push({
        widgetId: null,
        type: 'layout',
        suggestion: 'Consider breaking up long forms into multiple steps',
        priority: 'medium',
        before: 'Single form with 10+ widgets',
        after: 'Multi-step form with 3-5 widgets per step'
      });
    }
    
    return optimizations;
  }

  async getProjectTypeSuggestions(projectName, projectDescription) {
    console.log('📊 Analyzing project type');
    
    // Simulate AI processing time
    await new Promise(resolve => setTimeout(resolve, 500));
    
    const name = (projectName || '').toLowerCase();
    const description = (projectDescription || '').toLowerCase();
    
    let projectType = 'other';
    let confidence = 0.5;
    const commonWidgets = [];
    let layoutPattern = 'single-column';
    let colorScheme = 'professional';
    
    // Determine project type
    if (name.includes('contact') || description.includes('contact')) {
      projectType = 'contact-form';
      confidence = 0.9;
      commonWidgets.push(
        this.createSuggestion('TextField', 'Name field', 'high', { label: 'Name', required: true }),
        this.createSuggestion('TextField', 'Email field', 'high', { label: 'Email', fieldType: 'email', required: true }),
        this.createSuggestion('TextField', 'Message field', 'high', { label: 'Message' }),
        this.createSuggestion('Button', 'Submit button', 'high', { text: 'Send Message' })
      );
      layoutPattern = 'single-column';
    } else if (name.includes('survey') || description.includes('survey')) {
      projectType = 'survey';
      confidence = 0.85;
      commonWidgets.push(
        this.createSuggestion('TextField', 'Survey question', 'high', { label: 'Question', required: true }),
        this.createSuggestion('Radio', 'Multiple choice', 'medium', { label: 'Options' }),
        this.createSuggestion('Checkbox', 'Check all that apply', 'medium', { label: 'Options' })
      );
      layoutPattern = 'single-column';
    } else if (name.includes('ecommerce') || description.includes('product')) {
      projectType = 'e-commerce';
      confidence = 0.8;
      commonWidgets.push(
        this.createSuggestion('Image', 'Product image', 'high', { label: 'Product Image' }),
        this.createSuggestion('TextField', 'Product name', 'high', { label: 'Product Name', required: true }),
        this.createSuggestion('TextField', 'Price', 'high', { label: 'Price', fieldType: 'number', required: true }),
        this.createSuggestion('TextField', 'Description', 'medium', { label: 'Description' })
      );
      layoutPattern = 'grid';
      colorScheme = 'modern';
    } else if (name.includes('registration') || description.includes('signup')) {
      projectType = 'registration';
      confidence = 0.9;
      commonWidgets.push(
        this.createSuggestion('TextField', 'Full Name', 'high', { label: 'Full Name', required: true }),
        this.createSuggestion('TextField', 'Email', 'high', { label: 'Email', fieldType: 'email', required: true }),
        this.createSuggestion('TextField', 'Password', 'high', { label: 'Password', fieldType: 'password', required: true }),
        this.createSuggestion('TextField', 'Confirm Password', 'high', { label: 'Confirm Password', fieldType: 'password', required: true })
      );
      layoutPattern = 'single-column';
    } else if (name.includes('login') || description.includes('signin')) {
      projectType = 'login';
      confidence = 0.9;
      commonWidgets.push(
        this.createSuggestion('TextField', 'Email', 'high', { label: 'Email', fieldType: 'email', required: true }),
        this.createSuggestion('TextField', 'Password', 'high', { label: 'Password', fieldType: 'password', required: true }),
        this.createSuggestion('Button', 'Login Button', 'high', { text: 'Login' })
      );
      layoutPattern = 'single-column';
    } else if (name.includes('feedback') || description.includes('review')) {
      projectType = 'feedback';
      confidence = 0.8;
      commonWidgets.push(
        this.createSuggestion('TextField', 'Your Name', 'high', { label: 'Your Name', required: true }),
        this.createSuggestion('TextField', 'Email', 'high', { label: 'Email', fieldType: 'email', required: true }),
        this.createSuggestion('TextField', 'Rating', 'medium', { label: 'Rating', fieldType: 'number' }),
        this.createSuggestion('TextField', 'Comments', 'medium', { label: 'Comments' })
      );
      layoutPattern = 'single-column';
    }
    
    return {
      projectType,
      confidence,
      commonWidgets,
      layoutPattern,
      colorScheme
    };
  }
}

export default new WidgetSuggestionService();
