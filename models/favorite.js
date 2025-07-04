const mongoose = require('mongoose');

const FavoriteSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  foodId: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Favorite', FavoriteSchema);
