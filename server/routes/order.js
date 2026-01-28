const express = require('express');
const router = express.Router();
const ProductOrder = require('../models/product_order');

// Create a new product order
router.post('/create', async (req, res) => {
    try {
        const { userId, items, totalAmount, address } = req.body;

        const newOrder = new ProductOrder({
            userId,
            items,
            totalAmount,
            address
        });

        await newOrder.save();
        res.status(201).json({
            success: true,
            message: 'Order placed successfully',
            order: newOrder
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to place order',
            error: error.message
        });
    }
});

// Get user orders
router.get('/user/:userId', async (req, res) => {
    try {
        const orders = await ProductOrder.find({ userId: req.params.userId }).sort({ date: -1 });
        res.status(200).json({
            success: true,
            orders
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch orders',
            error: error.message
        });
    }
});

module.exports = router;
