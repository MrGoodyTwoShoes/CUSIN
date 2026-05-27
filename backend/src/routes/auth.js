const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticateToken } = require('../middleware/auth');
const { authRateLimit } = require('../middleware/rateLimit');

// Register (phone-based)
router.post('/register', authRateLimit, authController.register);

// Verify phone (SMS code)
router.post('/verify-phone', authRateLimit, authController.verifyPhone);

// Login
router.post('/login', authRateLimit, authController.login);

// Get current user
router.get('/me', authenticateToken, authController.getMe);

module.exports = router;
