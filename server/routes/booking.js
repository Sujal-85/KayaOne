const express = require('express');
const router = express.Router();
const Booking = require('../models/booking');

// Create a new booking
router.post('/create', async (req, res) => {
    try {
        const {
            userId,
            patientName,
            patientPhone,
            tests,
            prescriptionPath,
            address,
            date,
            slot,
            totalAmount
        } = req.body;

        const newBooking = new Booking({
            userId,
            patientName,
            patientPhone,
            tests,
            prescriptionPath,
            address,
            date,
            slot,
            totalAmount
        });

        const savedBooking = await newBooking.save();
        res.status(201).json({
            success: true,
            message: 'Booking created successfully',
            booking: savedBooking
        });
    } catch (error) {
        console.error('Error creating booking:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create booking',
            error: error.message
        });
    }
});

// Get user bookings
router.get('/user/:userId', async (req, res) => {
    try {
        const bookings = await Booking.find({ userId: req.params.userId }).sort({ createdAt: -1 });
        res.status(200).json({
            success: true,
            bookings
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch bookings',
            error: error.message
        });
    }
});

module.exports = router;
