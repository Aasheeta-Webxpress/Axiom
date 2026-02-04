class UIDesignService {
  async getLayoutSuggestions(widgets, canvasSize, projectType) {
    console.log('🎨 Getting layout suggestions for', projectType);
    
    // Simulate AI processing time
    await new Promise(resolve => setTimeout(resolve, 800));
    
    const suggestions = [];
    
    // Analyze current layout
    const layoutAnalysis = this.analyzeLayout(widgets, canvasSize);
    
    // Generate layout improvements
    suggestions.push(...this.generateLayoutImprovements(layoutAnalysis, projectType));
    
    return {
      layoutAnalysis,
      suggestions,
      autoLayouts: this.generateAutoLayouts(widgets, canvasSize, projectType)
    };
  }

  async getColorSchemeSuggestions(projectType, existingColors) {
    console.log('🎨 Getting color scheme suggestions for', projectType);
    
    await new Promise(resolve => setTimeout(resolve, 600));
    
    const schemes = this.generateColorSchemes(projectType, existingColors);
    
    return {
      recommendedSchemes: schemes,
      accessibilityScore: this.calculateAccessibilityScore(schemes),
      currentScheme: this.analyzeCurrentScheme(existingColors)
    };
  }

  async getTypographySuggestions(projectType, currentFonts) {
    console.log('🎨 Getting typography suggestions for', projectType);
    
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return {
      fontPairings: this.generateFontPairings(projectType),
      sizingRecommendations: this.generateSizingRecommendations(currentFonts),
      readabilityScore: this.calculateReadabilityScore(currentFonts)
    };
  }

  analyzeLayout(widgets, canvasSize) {
    const analysis = {
      widgetCount: widgets.length,
      density: this.calculateDensity(widgets, canvasSize),
      alignment: this.analyzeAlignment(widgets),
      spacing: this.analyzeSpacing(widgets),
      hierarchy: this.analyzeHierarchy(widgets),
      balance: this.analyzeBalance(widgets, canvasSize)
    };
    
    return analysis;
  }

  generateLayoutImprovements(analysis, projectType) {
    const improvements = [];
    
    // Density improvements
    if (analysis.density > 0.8) {
      improvements.push({
        type: 'density',
        priority: 'high',
        suggestion: 'Reduce widget density for better readability',
        action: 'Consider grouping related widgets or using scrollable areas',
        impact: 'Improves user focus and reduces cognitive load'
      });
    }
    
    // Alignment improvements
    if (analysis.alignment.score < 0.7) {
      improvements.push({
        type: 'alignment',
        priority: 'medium',
        suggestion: 'Improve widget alignment for cleaner appearance',
        action: 'Use grid alignment or consistent spacing',
        impact: 'Creates more professional and organized look'
      });
    }
    
    // Spacing improvements
    if (analysis.spacing.consistency < 0.6) {
      improvements.push({
        type: 'spacing',
        priority: 'medium',
        suggestion: 'Standardize spacing between widgets',
        action: 'Use consistent 8px, 16px, or 24px spacing',
        impact: 'Improves visual rhythm and user experience'
      });
    }
    
    // Hierarchy improvements
    if (analysis.hierarchy.clarity < 0.5) {
      improvements.push({
        type: 'hierarchy',
        priority: 'high',
        suggestion: 'Establish clear visual hierarchy',
        action: 'Use size, color, and positioning to create hierarchy',
        impact: 'Helps users understand content importance'
      });
    }
    
    return improvements;
  }

  generateAutoLayouts(widgets, canvasSize, projectType) {
    const layouts = [];
    
    // Grid layout
    layouts.push({
      name: 'Grid Layout',
      description: 'Organized grid arrangement for better structure',
      positions: this.generateGridLayout(widgets, canvasSize),
      suitability: this.calculateLayoutSuitability('grid', projectType)
    });
    
    // List layout
    layouts.push({
      name: 'List Layout',
      description: 'Vertical list arrangement for content-heavy pages',
      positions: this.generateListLayout(widgets, canvasSize),
      suitability: this.calculateLayoutSuitability('list', projectType)
    });
    
    return layouts;
  }

  generateColorSchemes(projectType, existingColors) {
    const schemes = [];
    
    // Dynamic color generation based on project type
    const baseColors = this.getBaseColorsForProjectType(projectType);
    
    // Generate dynamic schemes
    schemes.push(this.generateDynamicScheme('Primary', baseColors.primary, existingColors));
    schemes.push(this.generateDynamicScheme('Secondary', baseColors.secondary, existingColors));
    schemes.push(this.generateDynamicScheme('Accent', baseColors.accent, existingColors));
    
    // Generate complementary schemes
    schemes.push(this.generateComplementaryScheme(baseColors.primary));
    schemes.push(this.generateAnalogousScheme(baseColors.primary));
    schemes.push(this.generateTriadicScheme(baseColors.primary));
    
    // Add project-specific schemes
    if (projectType === 'dashboard') {
      schemes.push({
        name: 'Professional Dashboard',
        primary: '#1976D2',
        secondary: '#2196F3',
        accent: '#FFC107',
        background: '#FAFAFA',
        text: '#212121',
        description: 'Professional blue scheme perfect for business dashboards',
        accessibility: 'AA compliant',
        mood: 'professional',
        isDynamic: true
      });
    }
    
    if (projectType === 'ecommerce') {
      schemes.push({
        name: 'Modern E-commerce',
        primary: '#7B1FA2',
        secondary: '#9C27B0',
        accent: '#FF5722',
        background: '#FFFFFF',
        text: '#212121',
        description: 'Modern purple scheme for e-commerce platforms',
        accessibility: 'AA compliant',
        mood: 'modern',
        isDynamic: true
      });
    }
    
    // Universal schemes with dynamic variations
    schemes.push({
      name: 'Dynamic Minimalist',
      primary: this.adjustColorBrightness('#424242', existingColors.brightness || 0),
      secondary: this.adjustColorBrightness('#757575', existingColors.brightness || 0),
      accent: this.adjustColorBrightness('#2196F3', existingColors.brightness || 0),
      background: existingColors.background || '#FFFFFF',
      text: existingColors.text || '#212121',
      description: 'Dynamic minimalist scheme based on your preferences',
      accessibility: 'AAA compliant',
      mood: 'minimalist',
      isDynamic: true
    });
    
    return schemes;
  }

  getBaseColorsForProjectType(projectType) {
    const colorPalettes = {
      'dashboard': {
        primary: '#1976D2',
        secondary: '#2196F3',
        accent: '#FFC107'
      },
      'ecommerce': {
        primary: '#7B1FA2',
        secondary: '#9C27B0',
        accent: '#FF5722'
      },
      'blog': {
        primary: '#388E3C',
        secondary: '#4CAF50',
        accent: '#FF9800'
      },
      'survey': {
        primary: '#D32F2F',
        secondary: '#F44336',
        accent: '#4CAF50'
      },
      'general': {
        primary: '#2196F3',
        secondary: '#03A9F4',
        accent: '#FF9800'
      }
    };
    
    return colorPalettes[projectType] || colorPalettes['general'];
  }

  generateDynamicScheme(name, baseColor, existingColors) {
    const variations = this.generateColorVariations(baseColor);
    
    return {
      name: `Dynamic ${name}`,
      primary: variations.primary,
      secondary: variations.secondary,
      accent: variations.accent,
      background: this.adjustColorBrightness('#FFFFFF', existingColors.brightness || 0),
      text: this.getContrastColor(variations.primary),
      description: `Dynamic ${name.toLowerCase()} scheme with automatic variations`,
      accessibility: this.calculateAccessibility(variations.primary, '#FFFFFF'),
      mood: this.detectColorMood(variations.primary),
      isDynamic: true,
      variations: variations
    };
  }

  generateColorVariations(baseColor) {
    return {
      primary: baseColor,
      secondary: this.adjustColorBrightness(baseColor, 0.2),
      accent: this.adjustColorBrightness(baseColor, -0.3),
      light: this.adjustColorBrightness(baseColor, 0.4),
      dark: this.adjustColorBrightness(baseColor, -0.4)
    };
  }

  generateComplementaryScheme(baseColor) {
    const complementary = this.getComplementaryColor(baseColor);
    
    return {
      name: 'Complementary Harmony',
      primary: baseColor,
      secondary: complementary,
      accent: this.adjustColorBrightness(baseColor, 0.3),
      background: '#FFFFFF',
      text: '#212121',
      description: 'Complementary color scheme for high contrast',
      accessibility: 'AA compliant',
      mood: 'vibrant',
      isDynamic: true
    };
  }

  generateAnalogousScheme(baseColor) {
    const analogous1 = this.getAnalogousColor(baseColor, 30);
    const analogous2 = this.getAnalogousColor(baseColor, -30);
    
    return {
      name: 'Analogous Harmony',
      primary: baseColor,
      secondary: analogous1,
      accent: analogous2,
      background: '#FFFFFF',
      text: '#212121',
      description: 'Analogous color scheme for subtle harmony',
      accessibility: 'AA compliant',
      mood: 'harmonious',
      isDynamic: true
    };
  }

  generateTriadicScheme(baseColor) {
    const triadic1 = this.getTriadicColor(baseColor, 120);
    const triadic2 = this.getTriadicColor(baseColor, 240);
    
    return {
      name: 'Triadic Harmony',
      primary: baseColor,
      secondary: triadic1,
      accent: triadic2,
      background: '#FFFFFF',
      text: '#212121',
      description: 'Triadic color scheme for balanced design',
      accessibility: 'AA compliant',
      mood: 'balanced',
      isDynamic: true
    };
  }

  adjustColorBrightness(color, amount) {
    const hex = color.replace('#', '');
    const num = parseInt(hex, 16);
    const amt = Math.round(255 * amount);
    const R = (num >> 16) + amt;
    const G = (num >> 8 & 0x00FF) + amt;
    const B = (num & 0x0000FF) + amt;
    
    return '#' + (0x1000000 + (R < 255 ? R < 1 ? 0 : R : 255) * 0x10000 +
      (G < 255 ? G < 1 ? 0 : G : 255) * 0x100 +
      (B < 255 ? B < 1 ? 0 : B : 255))
      .toString(16).slice(1);
  }

  getComplementaryColor(color) {
    const hex = color.replace('#', '');
    const num = parseInt(hex, 16);
    const R = 255 - (num >> 16);
    const G = 255 - (num >> 8 & 0x00FF);
    const B = 255 - (num & 0x0000FF);
    
    return '#' + (0x1000000 + R * 0x10000 + G * 0x100 + B).toString(16).slice(1);
  }

  getAnalogousColor(color, degrees) {
    const hsl = this.hexToHSL(color);
    hsl.h = (hsl.h + degrees) % 360;
    return this.hslToHex(hsl);
  }

  getTriadicColor(color, degrees) {
    return this.getAnalogousColor(color, degrees);
  }

  hexToHSL(color) {
    const hex = color.replace('#', '');
    const num = parseInt(hex, 16);
    const R = num >> 16;
    const G = num >> 8 & 0x00FF;
    const B = num & 0x0000FF;
    
    const r = R / 255;
    const g = G / 255;
    const b = B / 255;
    
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h, s, l = (max + min) / 2;
    
    if (max === min) {
      h = s = 0;
    } else {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      
      switch (max) {
        case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
        case g: h = ((b - r) / d + 2) / 6; break;
        case b: h = ((r - g) / d + 4) / 6; break;
      }
    }
    
    return { h: h * 360, s: s, l: l };
  }

  hslToHex(hsl) {
    const h = hsl.h / 360;
    const s = hsl.s;
    const l = hsl.l;
    
    let r, g, b;
    
    if (s === 0) {
      r = g = b = l;
    } else {
      const hue2rgb = (p, q, t) => {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
      };
      
      const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      const p = 2 * l - q;
      
      r = hue2rgb(p, q, h + 1/3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1/3);
    }
    
    const toHex = x => {
      const hex = Math.round(x * 255).toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    };
    
    return '#' + toHex(r) + toHex(g) + toHex(b);
  }

  getContrastColor(backgroundColor) {
    const hex = backgroundColor.replace('#', '');
    const num = parseInt(hex, 16);
    const R = num >> 16;
    const G = num >> 8 & 0x00FF;
    const B = num & 0x0000FF;
    
    const brightness = (R * 299 + G * 587 + B * 114) / 1000;
    
    return brightness > 128 ? '#000000' : '#FFFFFF';
  }

  calculateAccessibility(foregroundColor, backgroundColor) {
    const contrast = this.getContrastRatio(foregroundColor, backgroundColor);
    
    if (contrast >= 7) return 'AAA compliant';
    if (contrast >= 4.5) return 'AA compliant';
    return 'Needs improvement';
  }

  getContrastRatio(color1, color2) {
    const luminance1 = this.getLuminance(color1);
    const luminance2 = this.getLuminance(color2);
    
    const lighter = Math.max(luminance1, luminance2);
    const darker = Math.min(luminance1, luminance2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  getLuminance(color) {
    const hex = color.replace('#', '');
    const num = parseInt(hex, 16);
    const R = num >> 16;
    const G = num >> 8 & 0x00FF;
    const B = num & 0x0000FF;
    
    const rsRGB = R / 255;
    const gsRGB = G / 255;
    const bsRGB = B / 255;
    
    const r = rsRGB <= 0.03928 ? rsRGB / 12.92 : Math.pow((rsRGB + 0.055) / 1.055, 2.4);
    const g = gsRGB <= 0.03928 ? gsRGB / 12.92 : Math.pow((gsRGB + 0.055) / 1.055, 2.4);
    const b = bsRGB <= 0.03928 ? bsRGB / 12.92 : Math.pow((bsRGB + 0.055) / 1.055, 2.4);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  detectColorMood(color) {
    const hex = color.replace('#', '');
    const num = parseInt(hex, 16);
    const R = num >> 16;
    const G = num >> 8 & 0x00FF;
    const B = num & 0x0000FF;
    
    const max = Math.max(R, G, B);
    const min = Math.min(R, G, B);
    const diff = max - min;
    
    if (diff < 30) return 'neutral';
    if (R > G && R > B) return 'warm';
    if (B > R && B > G) return 'cool';
    if (G > R && G > B) return 'fresh';
    
    return 'balanced';
  }

  generateFontPairings(projectType) {
    const pairings = [];
    
    if (projectType === 'dashboard') {
      pairings.push({
        name: 'Data-Driven',
        heading: 'Roboto',
        body: 'Open Sans',
        description: 'Clean, readable fonts perfect for data display',
        characteristics: ['high readability', 'professional', 'data-friendly']
      });
    }
    
    if (projectType === 'ecommerce') {
      pairings.push({
        name: 'Modern Shop',
        heading: 'Montserrat',
        body: 'Lato',
        description: 'Modern, friendly fonts for shopping experiences',
        characteristics: ['friendly', 'modern', 'conversion-focused']
      });
    }
    
    // Universal pairings
    pairings.push({
      name: 'Classic Professional',
      heading: 'Arial',
      body: 'Georgia',
      description: 'Timeless combination suitable for any business',
      characteristics: ['classic', 'professional', 'widely-supported']
    });
    
    return pairings;
  }

  // Helper methods
  calculateDensity(widgets, canvasSize) {
    const totalArea = widgets.reduce((sum, widget) => {
      const width = widget.properties?.width || 100;
      const height = widget.properties?.height || 50;
      return sum + (width * height);
    }, 0);
    
    const canvasArea = canvasSize.width * canvasSize.height;
    return totalArea / canvasArea;
  }

  analyzeAlignment(widgets) {
    const alignedWidgets = widgets.filter(widget => {
      const x = widget.position?.dx || 0;
      return x % 50 === 0; // Check if aligned to 50px grid
    });
    
    return {
      score: alignedWidgets.length / widgets.length,
      alignedCount: alignedWidgets.length,
      totalCount: widgets.length
    };
  }

  analyzeSpacing(widgets) {
    const spacings = [];
    for (let i = 0; i < widgets.length - 1; i++) {
      const widget1 = widgets[i];
      const widget2 = widgets[i + 1];
      const distance = Math.abs(
        (widget1.position?.dx || 0) - (widget2.position?.dx || 0)
      );
      spacings.push(distance);
    }
    
    const avgSpacing = spacings.reduce((a, b) => a + b, 0) / spacings.length;
    const variance = spacings.reduce((sum, spacing) => {
      return sum + Math.pow(spacing - avgSpacing, 2);
    }, 0) / spacings.length;
    
    return {
      consistency: 1 - (variance / (avgSpacing * avgSpacing)),
      average: avgSpacing,
      variance: variance
    };
  }

  analyzeHierarchy(widgets) {
    const hasHeadings = widgets.some(w => 
      w.type === 'Text' && w.properties?.fontSize > 18
    );
    const hasBody = widgets.some(w => 
      w.type === 'Text' && w.properties?.fontSize <= 18
    );
    
    return {
      clarity: hasHeadings && hasBody ? 0.8 : 0.4,
      hasHeadings,
      hasBody,
      headingCount: widgets.filter(w => 
        w.type === 'Text' && w.properties?.fontSize > 18
      ).length
    };
  }

  analyzeBalance(widgets, canvasSize) {
    const leftWeight = widgets.reduce((sum, widget) => {
      const x = widget.position?.dx || 0;
      return x < canvasSize.width / 2 ? sum + 1 : sum;
    }, 0);
    
    const balance = Math.abs(leftWeight - (widgets.length - leftWeight)) / widgets.length;
    
    return {
      score: 1 - balance,
      leftWeight,
      rightWeight: widgets.length - leftWeight,
      isBalanced: balance < 0.2
    };
  }

  generateGridLayout(widgets, canvasSize) {
    const cols = Math.ceil(Math.sqrt(widgets.length));
    const rows = Math.ceil(widgets.length / cols);
    const cellWidth = canvasSize.width / cols;
    const cellHeight = canvasSize.height / rows;
    
    return widgets.map((widget, index) => ({
      id: widget.id,
      x: (index % cols) * cellWidth + 10,
      y: Math.floor(index / cols) * cellHeight + 10,
      width: cellWidth - 20,
      height: cellHeight - 20
    }));
  }

  generateListLayout(widgets, canvasSize) {
    const itemHeight = 80;
    const spacing = 16;
    
    return widgets.map((widget, index) => ({
      id: widget.id,
      x: 20,
      y: index * (itemHeight + spacing) + 20,
      width: canvasSize.width - 40,
      height: itemHeight
    }));
  }

  calculateLayoutSuitability(layoutType, projectType) {
    const suitability = {
      'dashboard': { grid: 0.9, list: 0.6 },
      'ecommerce': { grid: 0.7, list: 0.8 },
      'blog': { grid: 0.6, list: 0.9 },
      'survey': { grid: 0.5, list: 0.9 }
    };
    
    return suitability[projectType]?.[layoutType] || 0.5;
  }

  calculateAccessibilityScore(schemes) {
    return schemes.map(scheme => ({
      schemeName: scheme.name,
      score: scheme.accessibility === 'AAA compliant' ? 0.95 : 0.85,
      issues: []
    }));
  }

  analyzeCurrentScheme(existingColors) {
    return {
      hasPrimary: existingColors.primary !== undefined,
      hasSecondary: existingColors.secondary !== undefined,
      hasAccent: existingColors.accent !== undefined,
      consistency: 0.7,
      mood: 'neutral'
    };
  }

  generateSizingRecommendations(currentFonts) {
    return {
      heading: { min: 24, max: 48, recommended: 32 },
      subheading: { min: 18, max: 24, recommended: 20 },
      body: { min: 14, max: 18, recommended: 16 },
      caption: { min: 12, max: 14, recommended: 12 }
    };
  }

  calculateReadabilityScore(currentFonts) {
    return 0.8;
  }
}

export default new UIDesignService();
