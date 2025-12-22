const mongoose = require('mongoose');

const dietPlanSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    metrics: {
        weight: Number, // in kg
        heightCentimeters: Number,
        feet: Number,
        inches: Number,
        region: String,
        medicalConditions: [String]
    },
    goals: {
        weightManagement: {
            type: String,
            enum: ['Weight Loss', 'Maintain Weight', 'Muscle Building']
        },
        foodChoice: {
            type: String,
            enum: ['Vegetarian', 'Non Vegetarian', 'Vegetarian + Egg', 'Vegan']
        },
        activityLevel: {
            type: String,
            enum: ['Sedentary', 'Light', 'Moderate', 'Active']
        }
    },
    analysis: {
        bmi: Number,
        bmiStatus: String,
        idealWeight: Number,
        suggestedKcal: Number
    },
    currentPlan: {
        generatedAt: Date,
        days: [{
            dayName: String, // Day 1, Day 2, etc.
            meals: [{
                mealType: String, // Breakfast, Lunch, Dinner, Snack
                foodName: String,
                calories: Number,
                protein: Number,
                carbs: Number,
                fats: Number
            }]
        }]
    },
    tracking: {
        dailyCaloriesEaten: {
            type: Number,
            default: 0
        },
        lastTrackedDate: {
            type: String // YYYY-MM-DD
        }
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('DietPlan', dietPlanSchema);
