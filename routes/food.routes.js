const express = require('express');
const router = express.Router();
const FoodItem = require('../models/fooditem');
const authMiddleware = require('../middleware/authMiddleware');
const foodController = require('../controllers/foodcontroller');
const roleMiddleware = require('../middleware/roleMiddleware');

// Get all food items (public)
router.get('/', async (req, res) => {
  try {
    const items = await FoodItem.find().sort({ createdAt: -1 });
    res.json(items);
  } catch (err) {
    res.status(500).json({ msg: 'Server error' });
  }
});

// Get single food item by ID (public)
router.get('/:id', async (req, res) => {
  try {
    const item = await FoodItem.findById(req.params.id);
    if (!item) {
      return res.status(404).json({ msg: 'Food item not found' });
    }
    res.json(item);
  } catch (err) {
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Food item not found' });
    }
    res.status(500).json({ msg: 'Server error' });
  }
});

// Get food items by provider (provider only)
router.get('/provider/:id', authMiddleware, roleMiddleware('provider'), async (req, res) => {
  try {
    const items = await FoodItem.find({ providerId: req.params.id });
    res.json(items);
  } catch (err) {
    res.status(500).json({ msg: 'Failed to fetch provider items' });
  }
});

// Create new food item (provider only)
router.post('/', authMiddleware, roleMiddleware('provider'), async (req, res) => {
  const { title, description, price, quantity, expiryDate, imageUrl } = req.body;

  if (!title || !description || !price || !quantity || !expiryDate) {
    return res.status(400).json({ msg: 'All fields are required' });
  }

  try {
    const newItem = new FoodItem({
      title,
      description,
      price,
      quantity,
      expiryDate,
      imageUrl,
      providerId: req.user.id,
    });

    await newItem.save();
    res.status(201).json(newItem);
  } catch (err) {
    res.status(500).json({ msg: 'Failed to create food item' });
  }
});

// Update existing food item (provider only)
router.put('/:id', authMiddleware, roleMiddleware('provider'), async (req, res) => {
  try {
    const item = await FoodItem.findById(req.params.id);

    if (!item) return res.status(404).json({ msg: 'Item not found' });
    if (item.providerId !== req.user.id) {
      return res.status(403).json({ msg: 'Not your item' });
    }

    const { title, description, price, quantity, expiryDate, imageUrl } = req.body;
    Object.assign(item, { title, description, price, quantity, expiryDate, imageUrl });

    await item.save();
    res.json(item);
  } catch (err) {
    res.status(500).json({ msg: 'Failed to update item' });
  }
});

// Delete food item (provider only)
router.delete('/:id', authMiddleware, roleMiddleware('provider'), async (req, res) => {
  try {
    const item = await FoodItem.findById(req.params.id);
    if (!item) return res.status(404).json({ msg: 'Item not found' });
    if (item.providerId !== req.user.id) {
      return res.status(403).json({ msg: 'Not your item' });
    }

    await item.deleteOne();
    res.json({ msg: 'Item deleted' });
  } catch (err) {
    res.status(500).json({ msg: 'Failed to delete item' });
  }
});

module.exports = router;
