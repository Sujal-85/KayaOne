const express = require('express');
const router = express.Router();
const DietPlan = require('../models/diet_plan');
const { ChatGoogleGenerativeAI } = require('@langchain/google-genai');
const { SystemMessage, HumanMessage } = require('@langchain/core/messages');

const model = new ChatGoogleGenerativeAI({
    model: "gemini-3-pro-preview",
    apiKey: process.env.GEMINI_API_KEY,
    temperature: 0.5,
});

// Update or Initial Create Metrics & Goals
router.post('/update-profile', async (req, res) => {
    try {
        const { userId, metrics, goals } = req.body;

        // Calculate BMI and status
        const heightMeters = (metrics.feet * 0.3048) + (metrics.inches * 0.0254);
        const bmi = (metrics.weight / (heightMeters * heightMeters)).toFixed(2);

        let bmiStatus = 'Normal';
        if (bmi < 18.5) bmiStatus = 'Underweight';
        else if (bmi >= 25 && bmi < 29.9) bmiStatus = 'Overweight';
        else if (bmi >= 30) bmiStatus = 'Obese';

        const idealWeight = (21.7 * (heightMeters * heightMeters)).toFixed(1);

        // Basic calorie estimation (BMR simplified)
        let suggestedKcal = 2000;
        if (goals.weightManagement === 'Weight Loss') suggestedKcal = 1500;
        else if (goals.weightManagement === 'Muscle Building') suggestedKcal = 2500;

        const analysis = {
            bmi,
            bmiStatus,
            idealWeight,
            suggestedKcal
        };

        let diet = await DietPlan.findOne({ userId });
        if (diet) {
            diet.metrics = metrics;
            diet.goals = goals;
            diet.analysis = analysis;
        } else {
            diet = new DietPlan({ userId, metrics, goals, analysis });
        }

        await diet.save();
        res.status(200).json({ success: true, diet });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Generate 7-Day Plan using AI
router.post('/generate-plan', async (req, res) => {
    try {
        const { userId } = req.body;
        const diet = await DietPlan.findOne({ userId });

        if (!diet) return res.status(404).json({ success: false, message: 'Profile not found' });

        const prompt = `Generate a 7-day personalized diet plan for a user with the following profile:
        - Weight: ${diet.metrics.weight}kg
        - Goal: ${diet.goals.weightManagement}
        - Diet Preference: ${diet.goals.foodChoice}
        - Activity: ${diet.goals.activityLevel}
        - Region: ${diet.metrics.region}
        - Medical Conditions: ${diet.metrics.medicalConditions.join(', ') || 'None'}
        - Target Calories: ${diet.analysis.suggestedKcal} kcal/day

        Return the plan in STRICT JSON format like this:
        {
            "days": [
                {
                    "dayName": "Day 1",
                    "meals": [
                        {"mealType": "Breakfast", "foodName": "...", "calories": 300, "protein": 20, "carbs": 40, "fats": 10},
                        ...
                    ]
                },
                ... up to Day 7
            ]
        }`;

        const response = await model.invoke([
            new SystemMessage("You are a professional nutritionist AI. Format replies as JSON only."),
            new HumanMessage(prompt)
        ]);

        // Clean output if Gemini wraps in markdown
        let content = response.content;
        if (content.includes('```json')) {
            content = content.split('```json')[1].split('```')[0].trim();
        }

        const planData = JSON.parse(content);
        diet.currentPlan = {
            generatedAt: new Date(),
            days: planData.days
        };

        await diet.save();
        res.status(200).json({ success: true, plan: diet.currentPlan });
    } catch (error) {
        console.error('AI Diet Plan Error:', error);
        res.status(500).json({ success: false, message: 'AI Generation Failed' });
    }
});

// Get User Diet Profile & Plan
router.get('/:userId', async (req, res) => {
    try {
        const diet = await DietPlan.findOne({ userId: req.params.userId });
        res.status(200).json({ success: true, diet });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Log daily calories
router.post('/log-calories', async (req, res) => {
    try {
        const { userId, calories } = req.body;
        const today = new Date().toISOString().split('T')[0];

        const diet = await DietPlan.findOne({ userId });
        if (!diet) return res.status(404).json({ success: false, message: 'Profile not found' });

        if (diet.tracking.lastTrackedDate === today) {
            diet.tracking.dailyCaloriesEaten += calories;
        } else {
            diet.tracking.lastTrackedDate = today;
            diet.tracking.dailyCaloriesEaten = calories;
        }

        await diet.save();
        res.status(200).json({ success: true, eaten: diet.tracking.dailyCaloriesEaten });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
