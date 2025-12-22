const express = require('express');
const router = express.Router();
const { ChatGoogleGenerativeAI } = require('@langchain/google-genai');
const { SystemMessage, HumanMessage } = require('@langchain/core/messages');

// Initialize Gemini Model
const model = new ChatGoogleGenerativeAI({
    model: "gemini-1.5-flash",
    apiKey: process.env.GEMINI_API_KEY,
    temperature: 0.7,
});

router.post('/chat', async (req, res) => {
    try {
        const { message, history } = req.body;

        if (!process.env.GEMINI_API_KEY) {
            return res.status(500).json({
                success: false,
                message: 'Gemini API Key missing in server environment.'
            });
        }

        const systemMessage = new SystemMessage(
            "You are MediGuide, a premium AI health assistant for the MediNest platform. " +
            "Provide helpful, empathetic, and professional health guidance. " +
            "Always clarify that you are an AI and not a substitute for professional medical advice. " +
            "Focus on wellness, preventative care, and explaining medical terms."
        );

        const messages = [systemMessage];

        // Add history if available
        if (history && Array.isArray(history)) {
            history.forEach(msg => {
                if (msg.role === 'user') messages.push(new HumanMessage(msg.content));
                else messages.push(new SystemMessage(msg.content));
            });
        }

        messages.push(new HumanMessage(message));

        const response = await model.invoke(messages);

        res.status(200).json({
            success: true,
            reply: response.content
        });
    } catch (error) {
        console.error('AI Chat Error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get AI response',
            error: error.message
        });
    }
});

module.exports = router;
