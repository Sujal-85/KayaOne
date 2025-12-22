const express = require('express');
const router = express.Router();
const User = require('../models/user');
const jwt = require('jsonwebtoken');

// Login or Register user (after Firebase Phone Verification)
router.post('/login', async (req, res) => {
    const { phoneNumber } = req.body;
    try {
        let user = await User.findOne({ phoneNumber });
        if (!user) {
            user = new User({ phoneNumber });
            await user.save();
        }
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });
        res.json({ token, user });
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
});

// Update user profile
router.post('/update-profile', async (req, res) => {
    const { phoneNumber, name, dob, email, city, profilePic } = req.body;
    try {
        const updateData = { name, dob, email, city, isProfileComplete: true };
        if (profilePic) updateData.profilePic = profilePic;

        const user = await User.findOneAndUpdate(
            { phoneNumber },
            updateData,
            { new: true }
        );
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
});

// Get user profile
router.get('/profile/:phoneNumber', async (req, res) => {
    try {
        const user = await User.findOne({ phoneNumber: req.params.phoneNumber });
        if (!user) return res.status(404).json({ message: 'User not found' });
        res.json(user);
    } catch (err) {
        res.status(500).json({ message: 'Server error' });
    }
});

module.exports = router;
