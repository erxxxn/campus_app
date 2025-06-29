const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  phone: { type: String },
  dob: { type: String },
  role: { type: String, enum: ['user', 'provider'], default: 'user' },
  // New fields for profile
  businessName: { type: String, default: '' }, // For food providers
  avatarUrl: { 
    type: String, 
    default: 'https://via.placeholder.com/150' 
  },
  // Timestamps
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Update the updatedAt field before saving
userSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('User', userSchema);