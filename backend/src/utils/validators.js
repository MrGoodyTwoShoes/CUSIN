// Validation utilities for CUSIN backend

class Validators {
  // Validate phone number (E.164 format)
  static validatePhone(phone) {
    if (!phone) return { valid: false, error: 'Phone number is required' };
    
    // Remove spaces, dashes, parentheses
    const cleaned = phone.replace(/[\s\-\(\)]/g, '');
    
    // E.164 format: + followed by 10-15 digits
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    
    if (!phoneRegex.test(cleaned)) {
      return { valid: false, error: 'Invalid phone number format' };
    }
    
    // Kenya-specific validation (optional)
    if (cleaned.startsWith('+254') && cleaned.length !== 13) {
      return { valid: false, error: 'Kenyan phone numbers must be 13 digits with country code' };
    }
    
    return { valid: true, cleaned };
  }

  // Validate coordinates
  static validateCoordinates(lat, lng) {
    const errors = [];
    
    if (lat === undefined || lat === null) {
      errors.push('Latitude is required');
    } else if (typeof lat !== 'number' || isNaN(lat)) {
      errors.push('Latitude must be a number');
    } else if (lat < -90 || lat > 90) {
      errors.push('Latitude must be between -90 and 90');
    }
    
    if (lng === undefined || lng === null) {
      errors.push('Longitude is required');
    } else if (typeof lng !== 'number' || isNaN(lng)) {
      errors.push('Longitude must be a number');
    } else if (lng < -180 || lng > 180) {
      errors.push('Longitude must be between -180 and 180');
    }
    
    return {
      valid: errors.length === 0,
      errors
    };
  }

  // Validate Kenya coordinates
  static validateKenyaCoordinates(lat, lng) {
    const coordValidation = this.validateCoordinates(lat, lng);
    if (!coordValidation.valid) {
      return coordValidation;
    }
    
    // Kenya bounds (approximate)
    const kenyaBounds = {
      minLat: -4.68,
      maxLat: 5.05,
      minLng: 33.91,
      maxLng: 41.91
    };
    
    if (lat < kenyaBounds.minLat || lat > kenyaBounds.maxLat) {
      return {
        valid: false,
        errors: ['Latitude is outside Kenya bounds']
      };
    }
    
    if (lng < kenyaBounds.minLng || lng > kenyaBounds.maxLng) {
      return {
        valid: false,
        errors: ['Longitude is outside Kenya bounds']
      };
    }
    
    return { valid: true };
  }

  // Validate incident type
  static validateIncidentType(type) {
    const validTypes = [
      'robbery',
      'assault',
      'harassment',
      'suspicious_activity',
      'accident',
      'violence',
      'kidnapping',
      'missing_person',
      'road_danger',
      'community_alert',
      'theft',
      'vandalism',
      'fraud',
      'other'
    ];
    
    if (!type) {
      return { valid: false, error: 'Incident type is required' };
    }
    
    if (!validTypes.includes(type)) {
      return { 
        valid: false, 
        error: `Invalid incident type. Must be one of: ${validTypes.join(', ')}` 
      };
    }
    
    return { valid: true };
  }

  // Validate severity level
  static validateSeverity(severity) {
    const validSeverities = ['low', 'medium', 'high', 'critical'];
    
    if (!severity) {
      return { valid: false, error: 'Severity is required' };
    }
    
    if (!validSeverities.includes(severity)) {
      return { 
        valid: false, 
        error: `Invalid severity. Must be one of: ${validSeverities.join(', ')}` 
      };
    }
    
    return { valid: true };
  }

  // Validate description
  static validateDescription(description, minLength = 10, maxLength = 1000) {
    if (!description) {
      return { valid: false, error: 'Description is required' };
    }
    
    if (typeof description !== 'string') {
      return { valid: false, error: 'Description must be a string' };
    }
    
    if (description.length < minLength) {
      return { 
        valid: false, 
        error: `Description must be at least ${minLength} characters` 
      };
    }
    
    if (description.length > maxLength) {
      return { 
        valid: false, 
        error: `Description must not exceed ${maxLength} characters` 
      };
    }
    
    // Check for suspicious patterns
    const suspiciousPatterns = [
      /^(test|asdf|qwerty|hello world)$/i,
      /^(.)\1{10,}$/,  // Repeated characters
      /^[0-9]+$/,  // Only numbers
    ];
    
    for (const pattern of suspiciousPatterns) {
      if (pattern.test(description.trim())) {
        return { 
          valid: false, 
          error: 'Description appears to be invalid or spam' 
        };
      }
    }
    
    return { valid: true };
  }

  // Validate email
  static validateEmail(email) {
    if (!email) {
      return { valid: false, error: 'Email is required' };
    }
    
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    
    if (!emailRegex.test(email)) {
      return { valid: false, error: 'Invalid email format' };
    }
    
    return { valid: true };
  }

  // Validate UUID
  static validateUUID(uuid) {
    if (!uuid) {
      return { valid: false, error: 'UUID is required' };
    }
    
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    
    if (!uuidRegex.test(uuid)) {
      return { valid: false, error: 'Invalid UUID format' };
    }
    
    return { valid: true };
  }

  // Validate pagination parameters
  static validatePagination(limit, offset) {
    const errors = [];
    
    if (limit !== undefined) {
      const limitNum = parseInt(limit);
      if (isNaN(limitNum) || limitNum < 1 || limitNum > 1000) {
        errors.push('Limit must be between 1 and 1000');
      }
    }
    
    if (offset !== undefined) {
      const offsetNum = parseInt(offset);
      if (isNaN(offsetNum) || offsetNum < 0) {
        errors.push('Offset must be a non-negative number');
      }
    }
    
    return {
      valid: errors.length === 0,
      errors,
      limit: limit ? Math.min(1000, Math.max(1, parseInt(limit))) : 50,
      offset: offset ? Math.max(0, parseInt(offset)) : 0
    };
  }

  // Sanitize user input
  static sanitizeInput(input) {
    if (typeof input !== 'string') {
      return input;
    }
    
    // Remove potential XSS vectors
    return input
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#x27;')
      .trim();
  }

  // Validate file upload
  static validateFileUpload(file, maxSizeMB = 10, allowedTypes = ['image/jpeg', 'image/png', 'image/webp']) {
    const errors = [];
    
    if (!file) {
      return { valid: false, error: 'File is required' };
    }
    
    // Check file size
    if (file.size > maxSizeMB * 1024 * 1024) {
      errors.push(`File size must not exceed ${maxSizeMB}MB`);
    }
    
    // Check file type
    if (!allowedTypes.includes(file.mimetype)) {
      errors.push(`File type must be one of: ${allowedTypes.join(', ')}`);
    }
    
    return {
      valid: errors.length === 0,
      errors
    };
  }

  // Validate circle type
  static validateCircleType(type) {
    const validTypes = ['community', 'family', 'campus', 'workplace', 'estate', 'transport'];
    
    if (!type) {
      return { valid: false, error: 'Circle type is required' };
    }
    
    if (!validTypes.includes(type)) {
      return { 
        valid: false, 
        error: `Invalid circle type. Must be one of: ${validTypes.join(', ')}` 
      };
    }
    
    return { valid: true };
  }

  // Validate contact type
  static validateContactType(type) {
    const validTypes = ['emergency', 'family', 'friend', 'work', 'other'];
    
    if (!type) {
      return { valid: false, error: 'Contact type is required' };
    }
    
    if (!validTypes.includes(type)) {
      return { 
        valid: false, 
        error: `Invalid contact type. Must be one of: ${validTypes.join(', ')}` 
      };
    }
    
    return { valid: true };
  }
}

module.exports = Validators;
