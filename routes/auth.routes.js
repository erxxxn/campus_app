const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'secret';


router.post('/signup', async (req, res) => {
  console.log('Signup body:', req.body); 
  
  const { name, email, phone, password, dob, role } = req.body;
  
  // Validation
  if (!name || !email || !password) {
    return res.status(400).json({ msg: 'Please fill all required fields' });
  }

  try {
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ msg: 'User already exists' });

    const hashed = await bcrypt.hash(password, 10);
    const newUser = new User({ name, email, password: hashed, phone, dob, role });
    await newUser.save();

    return res.status(201).json({ msg: 'Signup successful' });
  } catch (error) {
    console.error('Signup error:', error);
    return res.status(500).json({ msg: 'Server error during signup' });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(404).json({ msg: 'User not found' });

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) return res.status(400).json({ msg: 'Incorrect password' });

  const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '3d' });
  res.json({ token, role: user.role, userId: user._id });
});

module.exports = router;