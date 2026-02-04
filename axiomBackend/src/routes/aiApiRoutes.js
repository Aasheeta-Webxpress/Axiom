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
