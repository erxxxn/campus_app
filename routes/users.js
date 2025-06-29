const express = require('express');
const router = express.Router();
const User = require('../models/user');
const auth = require('../middleware/authMiddleware');

// GET user profile
router.get('/:userId', auth, async (req, res) => {
  try {
    const user = await User.findById(req.params.userId)
      .select('-password -__v'); // Exclude sensitive data

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Format response based on user role
    const response = {
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      role: user.role
    };

    // Add businessName for providers
    if (user.role === 'provider') {
      response.businessName = user.businessName;
    }

    res.json(response);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;