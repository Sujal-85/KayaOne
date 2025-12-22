const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    phoneNumber: {
        type: String,
        required: true,
        unique: true
    },
    name: {
        type: String,
        default: ''
    },
    dob: {
        type: String,
        default: ''
    },
    email: {
        type: String,
        default: ''
    },
    city: {
        type: String,
        default: ''
    },
    isProfileComplete: {
        type: Boolean,
        default: false
    },
    profilePic: {
        type: String,
        default: ''
    }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
