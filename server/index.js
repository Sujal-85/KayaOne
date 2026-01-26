const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();
const cron = require('node-cron');
const axios = require('axios');


const authRoutes = require('./routes/auth');
const bookingRoutes = require('./routes/booking');
const doctorRoutes = require('./routes/doctor');
const aiRoutes = require('./routes/ai');
const dietRoutes = require('./routes/diet');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/booking', bookingRoutes);
app.use('/api/doctor', doctorRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/diet', dietRoutes);

// Health check endpoint
app.get('/ping', (req, res) => {
    res.status(200).send('pong');
});

// Global Error Handler
app.use((err, req, res, next) => {
    console.error('Global Error Handler:', err);
    res.status(500).json({
        success: false,
        message: 'Internal Server Error',
        error: err.message
    });
});


// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Could not connect to MongoDB', err));

// Export app for Google Cloud Functions
exports.api = app;

const PORT = process.env.PORT || 5000;

// Only listen if not running in a function environment (local dev)
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
}

// Cron job disabled for Cloud Functions (Serverless instances scale to zero)
// cron.schedule('*\/14 * * * *', async () => {
//    ...
// });

