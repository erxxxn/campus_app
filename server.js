require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/auth.routes');
const foodRoutes = require('./routes/food.routes');
const userRoutes = require('./routes/users');
const favoriteRoutes = require('./routes/favorites.routes');
const cartRoutes = require('./routes/cart.routes');
const orderRoutes = require('./routes/order.routes');
const connectDB = require('./config/db');


const app = express();

// Updated CORS configuration
const allowedOrigins = [
  'http://localhost',
  'http://localhost:3000',
  'http://localhost:5000',
  'http://localhost:59218',
  'http://172.20.10.4:5000',
  'http://172.20.10.4',
  'http://10.0.2.2:5000' // Added for Android emulator
];

app.use(cors({
  origin: function (origin, callback) {
    if (!origin || origin.startsWith('http://localhost')) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

// Middleware to log incoming requests
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Added root route
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Food Sharing API is running',
    endpoints: {
      auth: {
        login: 'POST /api/auth/login',
        signup: 'POST /api/auth/signup'
      },
      food: 'GET /api/food'
    }
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/food', foodRoutes);
app.use('/api/users', userRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Not found handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

const PORT = process.env.PORT || 5000;

// Connect to DB before starting server
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
    console.log(`Network accessible via http://172.20.10.4:${PORT}`);
  });
}).catch(err => {
  console.error('Database connection failed', err);
  process.exit(1);
});