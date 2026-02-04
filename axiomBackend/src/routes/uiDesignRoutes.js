import { Router } from 'express';
import uiDesignService from '../services/uiDesignService.js';

const router = Router();

// Get layout suggestions
router.post('/layout-suggestions', async (req, res) => {
  try {
    const { widgets, canvasSize, projectType } = req.body;
    
    if (!widgets || !canvasSize) {
      return res.status(400).json({ 
        error: 'Widgets and canvas size are required' 
      });
    }

    const suggestions = await uiDesignService.getLayoutSuggestions(
      widgets,
      canvasSize,
      projectType || 'general'
    );
    
    res.json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    console.error('Layout Suggestions Error:', error);
    res.status(500).json({ 
      error: 'Failed to get layout suggestions',
      message: error.message 
    });
  }
});

// Get color scheme suggestions
router.post('/color-schemes', async (req, res) => {
  try {
    const { projectType, existingColors } = req.body;
    
    const schemes = await uiDesignService.getColorSchemeSuggestions(
      projectType || 'general',
      existingColors || {}
    );
    
    res.json({
      success: true,
      data: schemes
    });
  } catch (error) {
    console.error('Color Scheme Error:', error);
    res.status(500).json({ 
      error: 'Failed to get color schemes',
      message: error.message 
    });
  }
});

// Get typography suggestions
router.post('/typography', async (req, res) => {
  try {
    const { projectType, currentFonts } = req.body;
    
    const typography = await uiDesignService.getTypographySuggestions(
      projectType || 'general',
      currentFonts || {}
    );
    
    res.json({
      success: true,
      data: typography
    });
  } catch (error) {
    console.error('Typography Error:', error);
    res.status(500).json({ 
      error: 'Failed to get typography suggestions',
      message: error.message 
    });
  }
});

export default router;
