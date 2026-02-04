const express = require('express');
const router = express.Router();
const Project = require('../models/Project');
const API = require('../models/ApiEndpoint');

/**
 * Handle user confirmations for pending actions
 */
router.post('/confirm', async (req, res) => {
  try {
    const { action, data, projectId } = req.body;
    
    if (!projectId) {
      return res.status(400).json({
        message: '❌ No project selected.',
        actionCompleted: false
      });
    }
    
    switch (action) {
      case 'create_api':
        return await handleCreateAPI(data, projectId);
      
      case 'create_form':
        return await handleCreateForm(data, projectId);
      
      case 'cancel':
        return res.json({
          message: '❌ Action cancelled.',
          actionCompleted: true
        });
      
      default:
        return res.status(400).json({
          message: '❌ Unknown action.',
          actionCompleted: false
        });
    }
  } catch (error) {
    console.error('Confirmation error:', error);
    res.status(500).json({
      message: `❌ Error: ${error.message}`,
      actionCompleted: false
    });
  }
});

/**
 * Handle API creation confirmation
 */
async function handleCreateAPI(apiConfig, projectId) {
  try {
    // Find the project
    const project = await Project.findById(projectId);
    if (!project) {
      throw new Error('Project not found');
    }
    
    // Create the API
    const newAPI = new API({
      name: apiConfig.name,
      method: apiConfig.method,
      endpoint: apiConfig.endpoint,
      description: apiConfig.description,
      requestSchema: apiConfig.requestSchema,
      responseSchema: apiConfig.responseSchema,
      databaseMapping: apiConfig.databaseMapping,
      projectId: projectId
    });
    
    await newAPI.save();
    
    // Add API to project
    project.apis.push(newAPI._id);
    await project.save();
    
    // Generate full API details
    const apiURL = `http://localhost:5000${apiConfig.endpoint}`;
    
    return {
      message: `✅ **API Created Successfully!**\n\n` +
              `**API Details:**\n` +
              `• Name: ${apiConfig.name}\n` +
              `• URL: ${apiURL}\n` +
              `• Method: ${apiConfig.method}\n` +
              `• Description: ${apiConfig.description}\n\n` +
              `**Request Schema:**\n` +
              `\`\`\`json\n${JSON.stringify(apiConfig.requestSchema, null, 2)}\n\`\`\`\n\n` +
              `**Response Schema:**\n` +
              `\`\`\`json\n${JSON.stringify(apiConfig.responseSchema, null, 2)}\n\`\`\`\n\n` +
              `**Database Mapping:**\n` +
              `\`\`\`json\n${JSON.stringify(apiConfig.databaseMapping, null, 2)}\n\`\`\`\n\n` +
              `🎉 API is now live and ready to use!`,
      
      data: {
        type: 'api_created',
        api: {
          id: newAPI._id,
          name: apiConfig.name,
          url: apiURL,
          method: apiConfig.method,
          endpoint: apiConfig.endpoint
        }
      },
      
      actionCompleted: true,
      
      suggestions: [
        'Create form from this API',
        'Test the API',
        'Show API documentation',
        'Create another API'
      ]
    };
    
  } catch (error) {
    console.error('API creation error:', error);
    return {
      message: `❌ Failed to create API: ${error.message}`,
      actionCompleted: false
    };
  }
}

/**
 * Handle form creation from API
 */
async function handleCreateForm(data, projectId) {
  try {
    const { apiId, formConfig } = data;
    
    // Find the API
    const api = await API.findById(apiId);
    if (!api) {
      throw new Error('API not found');
    }
    
    // Find the project
    const project = await Project.findById(projectId);
    if (!project) {
      throw new Error('Project not found');
    }
    
    // Generate form fields from API request schema
    const formFields = generateFormFields(api.requestSchema);
    
    // Create form screen
    const formScreen = {
      name: `${api.name} Form`,
      type: 'form',
      widgets: formFields,
      apiBinding: {
        endpoint: api.endpoint,
        method: api.method,
        apiId: api._id
      }
    };
    
    // Add screen to project
    project.screens.push(formScreen);
    await project.save();
    
    return {
      message: `✅ **Form Created Successfully!**\n\n` +
              `**Form Details:**\n` +
              `• Name: ${formScreen.name}\n` +
              `• Fields: ${formFields.length}\n` +
              `• API Binding: ${api.method} ${api.endpoint}\n\n` +
              `**Generated Fields:**\n` +
              formFields.map(field => `• ${field.label} (${field.type})`).join('\n') + '\n\n' +
              `🎉 Form is ready with automatic API binding!`,
      
      data: {
        type: 'form_created',
        form: {
          name: formScreen.name,
          fields: formFields,
          apiBinding: formScreen.apiBinding
        }
      },
      
      actionCompleted: true,
      
      suggestions: [
        'Test the form',
        'Customize form fields',
        'Add validation',
        'Create another form'
      ]
    };
    
  } catch (error) {
    console.error('Form creation error:', error);
    return {
      message: `❌ Failed to create form: ${error.message}`,
      actionCompleted: false
    };
  }
}

/**
 * Generate form fields from API request schema
 */
function generateFormFields(requestSchema) {
  const fields = [];
  
  if (requestSchema.properties) {
    Object.entries(requestSchema.properties).forEach(([key, schema]) => {
      const field = {
        id: key,
        type: mapSchemaToWidgetType(schema.type),
        label: formatLabel(key),
        required: schema.required || false,
        properties: {
          placeholder: `Enter ${formatLabel(key).toLowerCase()}`,
          ...getWidgetProperties(schema.type)
        }
      };
      
      fields.push(field);
    });
  }
  
  // Add submit button
  fields.push({
    id: 'submit',
    type: 'button',
    label: 'Submit',
    properties: {
      text: 'Submit',
      action: 'submit'
    }
  });
  
  return fields;
}

/**
 * Map schema type to widget type
 */
function mapSchemaToWidgetType(schemaType) {
  const typeMap = {
    'string': 'textField',
    'number': 'textField',
    'date': 'datePicker',
    'boolean': 'checkbox',
    'email': 'textField',
    'password': 'textField'
  };
  
  return typeMap[schemaType] || 'textField';
}

/**
 * Get widget properties based on field type
 */
function getWidgetProperties(schemaType) {
  const properties = {};
  
  switch (schemaType) {
    case 'email':
      properties.keyboardType = 'email';
      break;
    case 'password':
      properties.obscureText = true;
      break;
    case 'number':  
      properties.keyboardType = 'number';
      break;
    case 'date':
      properties.showDatePicker = true;
      break;
    case 'boolean':
      properties.value = false;
      break;
  }
  
  return properties;
}

/**
 * Format field label
 */
function formatLabel(key) {
  return key
    .replace(/_/g, ' ')
    .replace(/\b\w/g, l => l.toUpperCase());
}

module.exports = router;
