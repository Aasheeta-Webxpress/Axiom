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

export default router;
