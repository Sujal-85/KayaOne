const express = require('express');
const router = express.Router();
const Offer = require('../models/offer');

// Get all offers
router.get('/', async (req, res) => {
    try {
        const offers = await Offer.find();
        res.status(200).json({
            success: true,
            offers
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch offers',
            error: error.message
        });
    }
});

// Admin: Create offer
router.post('/create', async (req, res) => {
    try {
        const newOffer = new Offer(req.body);
        await newOffer.save();
        res.status(201).json({
            success: true,
            message: 'Offer created successfully',
            offer: newOffer
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to create offer',
            error: error.message
        });
    }
});

module.exports = router;
