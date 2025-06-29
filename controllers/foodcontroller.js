const FoodItem = require('../models/fooditem');

exports.addFood = async (req, res) => {
  const food = new FoodItem(req.body);
  await food.save();
  res.status(201).json(food);
};

exports.getAllFood = async (req, res) => {
  const items = await FoodItem.find();
  res.json(items);
};

exports.updateFood = async (req, res) => {
  const updated = await FoodItem.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json(updated);
};

exports.deleteFood = async (req, res) => {
  await FoodItem.findByIdAndDelete(req.params.id);
  res.json({ message: 'Deleted successfully' });
};

exports.getFoodById = async (req, res) => {
  try {
    const foodItem = await Food.findById(req.params.id);
    if (!foodItem) {
      return res.status(404).json({ message: 'Food item not found' });
    }
    res.json(foodItem);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
