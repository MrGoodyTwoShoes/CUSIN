// PII Detection and Content Sanitization
// Detects and redacts personally identifiable information from user-generated content

class PIIDetector {
  constructor() {
    // Kenyan phone number patterns
    this.phonePatterns = [
      /\+254[7]\d{8}/g,           // +2547XXXXXXXX
      /\+254[1]\d{8}/g,           // +2541XXXXXXXX
      /07\d{8}/g,                 // 07XXXXXXXX
      /01\d{8}/g,                 // 01XXXXXXXX
      /254[7]\d{8}/g,             // 2547XXXXXXXX
      /254[1]\d{8}/g,             // 2541XXXXXXXX
    ];

    // Email patterns
    this.emailPattern = /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;

    // ID number patterns (Kenyan National ID: 8 digits)
    this.idPattern = /\b\d{8}\b/g;

    // Address patterns (basic)
    this.addressPatterns = [
      /\d+\s+[A-Za-z]+\s+(Street|St|Road|Rd|Avenue|Ave|Lane|Ln|Drive|Dr|Way|Court|Ct|Place|Pl|Square|Sq)/gi,
      /[A-Za-z]+\s+(Estate|Apartment|Apt|Flat|House|Plot|Block)\s*\d*/gi,
    ];

    // Name patterns (basic - common Kenyan names)
    this.commonNames = [
      'John', 'Mary', 'Peter', 'Paul', 'James', 'Joseph', 'Michael', 'David',
      'Sarah', 'Elizabeth', 'Grace', 'Faith', 'Hope', 'Joy', 'Mercy',
      'Kamau', 'Njoroge', 'Wanjiku', 'Muthoni', 'Kinyanjui', 'Njuguna',
      'Ochieng', 'Otieno', 'Akinyi', 'Achieng', 'Omondi', 'Oduor',
      'Kipchoge', 'Kipkorir', 'Chepkoech', 'Chebet', 'Jepkosgei',
      'Mohamed', 'Abdi', 'Hassan', 'Ali', 'Fatuma', 'Aisha',
    ];

    // Doxxing keywords
    this.doxxingKeywords = [
      'address is', 'lives at', 'home address', 'phone number', 'email address',
      'real name', 'actual name', 'true identity', 'personal info', 'private info',
      'dox', 'doxxing', 'expose', 'reveal identity', 'home of', 'residence of',
    ];

    // Harassment/incitement patterns
    this.harassmentPatterns = [
      /kill\s+(him|her|them|that)/gi,
      /beat\s+(him|her|them|up)/gi,
      /attack\s+(him|her|them)/gi,
      /stone\s+(him|her|them)/gi,
      /lynch/gi,
      /mob\s+justice/gi,
      /take\s+law\s+into\s+own\s+hands/gi,
      /beat\s+to\s+death/gi,
      /burn\s+(him|her|them|alive)/gi,
    ];
  }

  // Detect PII in text
  detectPII(text) {
    if (!text || typeof text !== 'string') {
      return { hasPII: false, detected: [] };
    }

    const detected = [];

    // Check phone numbers
    for (const pattern of this.phonePatterns) {
      const matches = text.match(pattern);
      if (matches) {
        detected.push({ type: 'phone', matches, count: matches.length });
      }
    }

    // Check emails
    const emailMatches = text.match(this.emailPattern);
    if (emailMatches) {
      detected.push({ type: 'email', matches: emailMatches, count: emailMatches.length });
    }

    // Check ID numbers
    const idMatches = text.match(this.idPattern);
    if (idMatches) {
      detected.push({ type: 'id', matches: idMatches, count: idMatches.length });
    }

    // Check addresses
    for (const pattern of this.addressPatterns) {
      const matches = text.match(pattern);
      if (matches) {
        detected.push({ type: 'address', matches, count: matches.length });
      }
    }

    // Check for common names (contextual)
    const nameMatches = this.commonNames.filter(name => 
      new RegExp(`\\b${name}\\s+[A-Z][a-z]+\\b`, 'i').test(text)
    );
    if (nameMatches.length > 0) {
      detected.push({ type: 'potential_name', matches: nameMatches, count: nameMatches.length });
    }

    return {
      hasPII: detected.length > 0,
      detected,
      totalPII: detected.reduce((sum, item) => sum + item.count, 0),
    };
  }

  // Redact PII from text
  redactPII(text, replacement = '[REDACTED]') {
    if (!text || typeof text !== 'string') {
      return text;
    }

    let redacted = text;

    // Redact phone numbers
    for (const pattern of this.phonePatterns) {
      redacted = redacted.replace(pattern, replacement);
    }

    // Redact emails
    redacted = redacted.replace(this.emailPattern, replacement);

    // Redact ID numbers
    redacted = redacted.replace(this.idPattern, replacement);

    // Redact addresses
    for (const pattern of this.addressPatterns) {
      redacted = redacted.replace(pattern, replacement);
    }

    return redacted;
  }

  // Detect doxxing
  detectDoxxing(text) {
    if (!text || typeof text !== 'string') {
      return { isDoxxing: false, keywords: [] };
    }

    const foundKeywords = this.doxxingKeywords.filter(keyword =>
      text.toLowerCase().includes(keyword.toLowerCase())
    );

    const piiDetection = this.detectPII(text);

    // Flag as potential doxxing if doxxing keywords found AND PII present
    return {
      isDoxxing: foundKeywords.length > 0 && piiDetection.hasPII,
      keywords: foundKeywords,
      piiPresent: piiDetection.hasPII,
      confidence: Math.min(1, (foundKeywords.length * 0.3) + (piiDetection.totalPII * 0.2)),
    };
  }

  // Detect harassment or incitement
  detectHarassment(text) {
    if (!text || typeof text !== 'string') {
      return { isHarassment: false, patterns: [] };
    }

    const foundPatterns = [];

    for (const pattern of this.harassmentPatterns) {
      const matches = text.match(pattern);
      if (matches) {
        foundPatterns.push({ pattern: pattern.source, matches });
      }
    }

    return {
      isHarassment: foundPatterns.length > 0,
      patterns: foundPatterns,
      severity: foundPatterns.length >= 2 ? 'high' : foundPatterns.length === 1 ? 'medium' : 'low',
    };
  }

  // Comprehensive content safety check
  checkContentSafety(text) {
    const piiCheck = this.detectPII(text);
    const doxxingCheck = this.detectDoxxing(text);
    const harassmentCheck = this.detectHarassment(text);

    const overallRisk = this.calculateOverallRisk(piiCheck, doxxingCheck, harassmentCheck);

    return {
      safe: overallRisk < 0.5,
      riskLevel: overallRisk >= 0.8 ? 'high' : overallRisk >= 0.5 ? 'medium' : 'low',
      overallRisk,
      checks: {
        pii: piiCheck,
        doxxing: doxxingCheck,
        harassment: harassmentCheck,
      },
      recommendation: this.getRecommendation(overallRisk),
    };
  }

  // Calculate overall risk score
  calculateOverallRisk(piiCheck, doxxingCheck, harassmentCheck) {
    let risk = 0;

    // PII presence
    if (piiCheck.hasPII) {
      risk += Math.min(0.3, piiCheck.totalPII * 0.1);
    }

    // Doxxing
    if (doxxingCheck.isDoxxing) {
      risk += doxxingCheck.confidence * 0.5;
    }

    // Harassment
    if (harassmentCheck.isHarassment) {
      risk += harassmentCheck.severity === 'high' ? 0.4 : harassmentCheck.severity === 'medium' ? 0.3 : 0.2;
    }

    return Math.min(1, risk);
  }

  // Get recommendation based on risk level
  getRecommendation(risk) {
    if (risk >= 0.8) {
      return 'BLOCK - Content violates safety policies';
    } else if (risk >= 0.5) {
      return 'REVIEW - Content requires manual moderation';
    } else if (risk >= 0.3) {
      return 'SANITIZE - Auto-redact PII and publish';
    } else {
      return 'PUBLISH - Content is safe';
    }
  }

  // Sanitize content automatically
  sanitizeContent(text) {
    if (!text || typeof text !== 'string') {
      return text;
    }

    let sanitized = this.redactPII(text);

    // Remove or replace harassment patterns
    for (const pattern of this.harassmentPatterns) {
      sanitized = sanitized.replace(pattern, '[REMOVED]');
    }

    return sanitized;
  }
}

module.exports = new PIIDetector();
