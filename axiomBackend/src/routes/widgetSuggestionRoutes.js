import { Router } from 'express';
import widgetSuggestionService from '../services/widgetSuggestionService.js';

const router = Router();

// Get widget suggestions
router.post('/suggestions', async (req, res) => {
  try {
    const { projectContext, existingWidgets, userIntent } = req.body;
    
    if (!projectContext) {
      return res.status(400).json({ 
        error: 'Project context is required' 
      });
    }

    const suggestions = await widgetSuggestionService.getWidgetSuggestions(
      projectContext,
      existingWidgets || [],
      userIntent || ''
    );
    
    res.json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    console.error('Widget Suggestions Error:', error);
    res.status(500).json({ 
      error: 'Failed to get widget suggestions',
      message: error.message 
    });
  }
});

// Get widget optimizations
router.post('/optimizations', async (req, res) => {
  try {
    const { widgets, projectContext } = req.body;
    
    if (!widgets) {
      return res.status(400).json({ 
        error: 'Widgets data is required' 
      });
    }

    const optimizations = await widgetSuggestionService.getWidgetOptimization(
      widgets,
      projectContext || {}
    );
    
    res.json({
      success: true,
      data: optimizations
    });
  } catch (error) {
    console.error('Widget Optimizations Error:', error);
    res.status(500).json({ 
      error: 'Failed to get widget optimizations',
      message: error.message 
    });
  }
});

// Get project type suggestions
router.post('/project-type', async (req, res) => {
  try {
    const { projectName, projectDescription } = req.body;
    
    if (!projectName) {
      return res.status(400).json({ 
        error: 'Project name is required' 
      });
    }

    const typeSuggestions = await widgetSuggestionService.getProjectTypeSuggestions(
      projectName,
      projectDescription || ''
    );
    
    res.json({
      success: true,
      data: typeSuggestions
    });
  } catch (error) {
    console.error('Project Type Suggestions Error:', error);
    res.status(500).json({ 
      error: 'Failed to get project type suggestions',
      message: error.message 
    });
  }
});

export default router;
