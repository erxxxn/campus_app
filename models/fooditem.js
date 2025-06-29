const mongoose = require('mongoose');

const foodItemSchema = new mongoose.Schema({
  title: String,
  description: String,
  price: Number,
  quantity: Number,
  expiryDate: Date,
  providerId: String,
  imageUrl: String,
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('FoodItem', foodItemSchema);
