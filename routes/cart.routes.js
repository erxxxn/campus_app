const express = require('express');
const router = express.Router();
const Cart = require('../models/cart');
const authMiddleware = require('../middleware/authMiddleware');

// Get user's cart items
router.get('/', authMiddleware, async (req, res) => {
  try {
    const items = await Cart.find({ userId: req.user.id });
    res.json(items);
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch cart' });
  }
});

// Add or update a cart item
router.post('/', authMiddleware, async (req, res) => {
  const { foodId, quantity } = req.body;
  if (!foodId || !quantity) {
    return res.status(400).json({ msg: 'foodId and quantity are required' });
  }

  try {
    const exists = await Cart.findOne({ userId: req.user.id, foodId });
    if (exists) {
      exists.quantity = quantity;
      await exists.save();
      return res.json(exists);
    }

    const item = new Cart({ userId: req.user.id, foodId, quantity });
    await item.save();
    res.status(201).json(item);
  } catch (err) {
    res.status(500).json({ msg: 'Failed to add to cart' });
  }
});

// Remove item from cart
router.delete('/:foodId', authMiddleware, async (req, res) => {
  try {
    await Cart.deleteOne({ userId: req.user.id, foodId: req.params.foodId });
    res.json({ msg: 'Cart item removed' });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to remove cart item' });
  }
});

module.exports = router;
