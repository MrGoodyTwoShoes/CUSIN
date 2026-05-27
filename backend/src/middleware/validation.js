const { validationResult, body, param } = require('express-validator');

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Validation failed',
        details: errors.array(),
      },
    });
  }
  next();
};

const validateIncidentCreation = [
  body('incident_type')
    .notEmpty()
    .isIn(['robbery', 'harassment', 'violence', 'kidnapping', 'accident', 'suspicious_activity', 'missing_person', 'road_danger', 'community_alert'])
    .withMessage('Valid incident type is required'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Description must be less than 1000 characters'),
  body('latitude')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Valid latitude is required'),
  body('longitude')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Valid longitude is required'),
  body('severity')
    .optional()
    .isIn(['low', 'medium', 'high', 'critical'])
    .withMessage('Severity must be low, medium, high, or critical'),
  handleValidationErrors,
];

const validateIncidentUpdate = [
  param('id').isUUID().withMessage('Valid incident ID is required'),
  body('incident_type')
    .optional()
    .isIn(['robbery', 'harassment', 'violence', 'kidnapping', 'accident', 'suspicious_activity', 'missing_person', 'road_danger', 'community_alert']),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 1000 }),
  body('severity')
    .optional()
    .isIn(['low', 'medium', 'high', 'critical']),
  handleValidationErrors,
];

const validateCircleCreation = [
  body('name')
    .trim()
    .isLength({ min: 3, max: 100 })
    .withMessage('Circle name must be between 3 and 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 }),
  body('circle_type')
    .optional()
    .isIn(['community', 'estate', 'campus', 'workplace', 'transport']),
  handleValidationErrors,
];

const validateContactCreation = [
  body('contact_name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Contact name must be between 2 and 100 characters'),
  body('contact_phone')
    .trim()
    .matches(/^\+?[1-9]\d{1,14}$/)
    .withMessage('Valid phone number is required'),
  body('contact_type')
    .optional()
    .isIn(['emergency', 'family', 'friend']),
  handleValidationErrors,
];

module.exports = {
  handleValidationErrors,
  validateIncidentCreation,
  validateIncidentUpdate,
  validateCircleCreation,
  validateContactCreation,
};
