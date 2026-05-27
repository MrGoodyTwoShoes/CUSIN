const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { generalRateLimit } = require('../middleware/rateLimit');
const contactService = require('../services/contactService');
const logger = require('../config/logger');

// Add contact
router.post('/', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const contact = await contactService.addContact(req.user.id, req.body);
    res.status(201).json({
      success: true,
      data: { contact },
    });
  } catch (error) {
    logger.error('Error adding contact:', error);
    if (error.message === 'Invalid phone number') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'INVALID_PHONE',
          message: 'Invalid phone number',
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to add contact',
      },
    });
  }
});

// Get contacts
router.get('/', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const contacts = await contactService.getContacts(req.user.id, req.query);
    res.json({
      success: true,
      data: { contacts },
    });
  } catch (error) {
    logger.error('Error getting contacts:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve contacts',
      },
    });
  }
});

// Get contact by ID
router.get('/:id', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const contact = await contactService.getContactById(req.params.id, req.user.id);
    if (!contact) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Contact not found',
        },
      });
    }
    res.json({
      success: true,
      data: { contact },
    });
  } catch (error) {
    logger.error('Error getting contact:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve contact',
      },
    });
  }
});

// Update contact
router.put('/:id', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const contact = await contactService.updateContact(req.params.id, req.user.id, req.body);
    res.json({
      success: true,
      data: { contact },
    });
  } catch (error) {
    logger.error('Error updating contact:', error);
    if (error.message === 'Invalid phone number') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'INVALID_PHONE',
          message: 'Invalid phone number',
        },
      });
    }
    if (error.message === 'Contact not found' || error.message === 'No fields to update') {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: error.message,
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to update contact',
      },
    });
  }
});

// Delete contact
router.delete('/:id', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    await contactService.deleteContact(req.params.id, req.user.id);
    res.json({
      success: true,
      data: { message: 'Contact deleted successfully' },
    });
  } catch (error) {
    logger.error('Error deleting contact:', error);
    if (error.message === 'Contact not found') {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Contact not found',
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to delete contact',
      },
    });
  }
});

// Get emergency contacts
router.get('/emergency', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const contacts = await contactService.getEmergencyContacts(req.user.id);
    res.json({
      success: true,
      data: { contacts },
    });
  } catch (error) {
    logger.error('Error getting emergency contacts:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve emergency contacts',
      },
    });
  }
});

// Share location with contacts
router.post('/share-location', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { latitude, longitude, contact_ids } = req.body;
    const result = await contactService.shareLocationWithContacts(
      req.user.id,
      { latitude, longitude },
      contact_ids
    );
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error('Error sharing location:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to share location',
      },
    });
  }
});

// Escalate emergency
router.post('/escalate', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { incident_id, message } = req.body;
    const result = await contactService.escalateEmergency(req.user.id, incident_id, message);
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    logger.error('Error escalating emergency:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to escalate emergency',
      },
    });
  }
});

module.exports = router;
