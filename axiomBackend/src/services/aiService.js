import mockAIClient from './mockAIService.js';

class AIService {
  async generateAPIConfig(description) {
    try {
      console.log('🤖 Generating API config for:', description);
      
      const config = await mockAIClient.generateAPIConfig(description);
      
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
    return await mockAIClient.suggestAPIImprovements(existingConfig);
  }

  // Missing methods that AI Agent Service needs
  async analyzeIntent(message, history, context) {
    const desc = message.toLowerCase();
    
    if (desc.includes('create') && desc.includes('api')) {
      return { type: 'create_api', confidence: 0.9 };
    }
    if (desc.includes('create') && desc.includes('project')) {
      return { type: 'create_project', confidence: 0.9 };
    }
    if (desc.includes('design') || desc.includes('ui')) {
      return { type: 'design_ui', confidence: 0.8 };
    }
    
    return { type: 'general_help', confidence: 0.5 };
  }

  async extractProjectDetails(message) {
    return {
      name: 'Generated Project',
      description: message,
      type: 'web',
      needsAuth: message.toLowerCase().includes('auth') || message.toLowerCase().includes('login')
    };
  }

  async generateFormConfig(message) {
    return {
      name: 'Generated Form',
      widgets: [
        { type: 'TextField', label: 'Name', required: true },
        { type: 'TextField', label: 'Email', required: true },
        { type: 'Button', label: 'Submit' }
      ],
      apiBinding: null
    };
  }

  async generateResponse(message, context) {
    return {
      text: 'I can help you create APIs, forms, and projects. What would you like to build?',
      suggestions: ['Create API', 'Create Form', 'Create Project']
    };
  }

  async generateProjectConfig(description) {
    return {
      type: 'web',
      screens: [{
        id: 'screen_1',
        name: 'Home',
        route: '/',
        widgets: []
      }],
      apis: [],
      settings: {
        theme: 'default',
        authentication: false
      }
    };
  }
}

export default new AIService();
