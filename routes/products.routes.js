const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const checkRole = require('../middleware/roleMiddleware');

router.get('/provider/products', auth, checkRole('provider'), (req, res) => {
  res.json({ message: 'This is for food providers only' });
});

router.get('/user/browse', auth, checkRole('user'), (req, res) => {
  res.json({ message: 'This is for regular users only' });
});

module.exports = router;
