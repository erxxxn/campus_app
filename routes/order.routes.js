const express = require('express');
const router = express.Router();
const authenticate = require('../middleware/authMiddleware');
const Food = require('../models/fooditem');
const Order = require('../models/order');

// POST /api/orders
router.post('/', authenticate, async (req, res) => {
  const userId = req.user.id;
  const { cartItems } = req.body;

  if (!Array.isArray(cartItems) || cartItems.length === 0) {
    return res.status(400).json({ msg: 'Cart is empty or invalid format.' });
  }

  let totalAmount = 0;
  const itemsWithPrice = [];

  try {
    for (const item of cartItems) {
      if (!item.foodId || typeof item.quantity !== 'number' || item.quantity <= 0) {
        return res.status(400).json({ msg: 'Invalid cart item format.' });
      }

      const food = await Food.findById(item.foodId);
      if (!food) {
        return res.status(404).json({ msg: `Food item ${item.foodId} not found.` });
      }

      const subtotal = food.price * item.quantity;
      totalAmount += subtotal;

      itemsWithPrice.push({
        foodId: item.foodId,
        quantity: item.quantity,
        price: food.price
      });
    }

    const newOrder = new Order({
      userId,
      items: itemsWithPrice,
      totalAmount,
    });

    await newOrder.save();

    res.status(201).json({ msg: 'Order placed successfully.', order: newOrder });
  } catch (error) {
    console.error('Order error:', error);
    res.status(500).json({ msg: 'Server error while placing order.' });
  }
});

module.exports = router;
