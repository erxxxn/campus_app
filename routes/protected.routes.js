const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const checkRole = require('../middleware/roleMiddleware');

router.get('/provider-area', auth, checkRole('provider'), (req, res) => {
  res.json({ message: 'Welcome, provider!' });
});

router.get('/user-area', auth, checkRole('user'), (req, res) => {
  res.json({ message: 'Welcome, user!' });
});

module.exports = router;
