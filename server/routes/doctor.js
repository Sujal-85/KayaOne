const express = require('express');
const router = express.Router();
const DoctorBooking = require('../models/doctor_booking');

// Create a doctor booking
router.post('/book', async (req, res) => {
    try {
        const {
            userId,
            doctorId,
            doctorName,
            appointmentDate,
            appointmentSlot,
            fee
        } = req.body;

        const newBooking = new DoctorBooking({
            userId,
            doctorId,
            doctorName,
            appointmentDate,
            appointmentSlot,
            fee
        });

        const savedBooking = await newBooking.save();
        res.status(201).json({
            success: true,
            message: 'Doctor appointment booked successfully',
            booking: savedBooking
        });
    } catch (error) {
        console.error('Error booking doctor:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to book doctor appointment',
            error: error.message
        });
    }
});

// Get user appointments
router.get('/user/:userId', async (req, res) => {
    try {
        const bookings = await DoctorBooking.find({ userId: req.params.userId }).sort({ appointmentDate: -1 });
        res.status(200).json({
            success: true,
            bookings
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch appointments',
            error: error.message
        });
    }
});

module.exports = router;
