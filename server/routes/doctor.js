const express = require('express');
const router = express.Router();
const Doctor = require('../models/doctor');
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

// Get all doctors
router.get('/', async (req, res) => {
    try {
        const doctors = await Doctor.find();
        res.status(200).json({
            success: true,
            doctors
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch doctors',
            error: error.message
        });
    }
});

// Admin: Add a doctor
router.post('/create', async (req, res) => {
    try {
        const Doctor = require('../models/doctor');
        const newDoctor = new Doctor(req.body);
        await newDoctor.save();
        res.status(201).json({
            success: true,
            message: 'Doctor added successfully',
            doctor: newDoctor
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to add doctor',
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
