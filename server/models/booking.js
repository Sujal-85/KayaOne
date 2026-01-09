const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    patientName: {
        type: String,
        required: true
    },
    patientPhone: {
        type: String,
        required: true
    },
    tests: [{
        name: String,
        price: Number,
        category: String
    }],
    prescriptionPath: {
        type: String
    },
    address: {
        type: String,
        required: true
    },
    date: {
        type: String,
        required: true
    },
    slot: {
        type: String,
        required: true
    },
    totalAmount: {
        type: Number,
        required: true
    },
    status: {
        type: String,
        enum: ['Pending', 'Confirmed', 'Phlebotomist Assigned', 'Out for Collection', 'Sample Collected', 'Lab Processing', 'Report Generated', 'Completed', 'Cancelled'],
        default: 'Pending'
    },
    trackingHistory: [{
        status: String,
        timestamp: { type: Date, default: Date.now },
        message: String
    }],
    phlebotomist: {
        name: String,
        phone: String,
        rating: Number,
        photoUrl: String
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Booking', bookingSchema);
