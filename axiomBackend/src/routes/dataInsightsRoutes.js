import { Router } from 'express';
import dataInsightsService from '../services/dataInsightsService.js';

const router = Router();

// Get form completion insights
router.post('/form-completion', async (req, res) => {
  try {
    const { projectId, formId } = req.body;
    
    if (!projectId || !formId) {
      return res.status(400).json({ 
        error: 'Project ID and Form ID are required' 
      });
    }

    const insights = await dataInsightsService.getFormCompletionInsights(
      projectId,
      formId
    );
    
    res.json({
      success: true,
      data: insights
    });
  } catch (error) {
    console.error('Form Completion Insights Error:', error);
    res.status(500).json({ 
      error: 'Failed to get form completion insights',
      message: error.message 
    });
  }
});

// Get data pattern recognition
router.post('/data-patterns', async (req, res) => {
  try {
    const { projectId, dataType, sampleData } = req.body;
    
    if (!projectId || !dataType) {
      return res.status(400).json({ 
        error: 'Project ID and Data Type are required' 
      });
    }

    const patterns = await dataInsightsService.getDataPatternRecognition(
      projectId,
      dataType
    );
    
    res.json({
      success: true,
      data: patterns
    });
  } catch (error) {
    console.error('Data Pattern Recognition Error:', error);
    res.status(500).json({ 
      error: 'Failed to analyze data patterns',
      message: error.message 
    });
  }
});

// Get performance recommendations
router.post('/performance-recommendations', async (req, res) => {
  try {
    const { projectId, apiUsage } = req.body;
    
    if (!projectId) {
      return res.status(400).json({ 
        error: 'Project ID is required' 
      });
    }

    const recommendations = await dataInsightsService.getPerformanceRecommendations(
      projectId,
      apiUsage || []
    );
    
    res.json({
      success: true,
      data: recommendations
    });
  } catch (error) {
    console.error('Performance Recommendations Error:', error);
    res.status(500).json({ 
      error: 'Failed to get performance recommendations',
      message: error.message 
    });
  }
});

export default router;
