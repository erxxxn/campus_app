const express = require('express');
const router = express.Router();
const Favorite = require('../models/favorite');
const authMiddleware = require('../middleware/authMiddleware');

// ✅ Check if a food item is favorited
router.get('/check/:foodId', authMiddleware, async (req, res) => {
  try {
    const fav = await Favorite.findOne({ userId: req.user.id, foodId: req.params.foodId });
    res.json({ isFavorite: !!fav });
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// ✅ Add to favorites
router.post('/add', authMiddleware, async (req, res) => {
  const { foodId } = req.body;
  try {
    const exists = await Favorite.findOne({ userId: req.user.id, foodId });
    if (exists) return res.status(400).json({ msg: 'Already in favorites' });

    const newFav = new Favorite({ userId: req.user.id, foodId });
    await newFav.save();
    res.status(201).json({ msg: 'Added to favorites' });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to add to favorites' });
  }
});

// ✅ Remove from favorites
router.delete('/remove/:foodId', authMiddleware, async (req, res) => {
  try {
    await Favorite.deleteOne({ userId: req.user.id, foodId: req.params.foodId });
    res.json({ msg: 'Removed from favorites' });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to remove from favorites' });
  }
});

module.exports = router;
