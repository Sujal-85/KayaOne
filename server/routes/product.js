const express = require('express');
const router = express.Router();
const Product = require('../models/product');

// Get all products (with optional category filter)
router.get('/', async (req, res) => {
    try {
        const { category, type } = req.query;
        let query = {};
        if (category) query.category = category;
        if (type === 'best_seller') query.isBestSeller = true;

        const products = await Product.find(query);
        res.status(200).json({
            success: true,
            products
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to fetch products',
            error: error.message
        });
    }
});

// Admin: Add a product
router.post('/create', async (req, res) => {
    try {
        const newProduct = new Product(req.body);
        await newProduct.save();
        res.status(201).json({
            success: true,
            message: 'Product added successfully',
            product: newProduct
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Failed to add product',
            error: error.message
        });
    }
});

module.exports = router;
