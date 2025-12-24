const express = require('express');
const router = express.Router();
const { ChatGoogleGenerativeAI } = require('@langchain/google-genai');
const { SystemMessage, HumanMessage, AIMessage } = require('@langchain/core/messages');
const { GoogleGenerativeAI } = require("@google/generative-ai");

// Initialize Langchain Gemini Model for Chat
const chatModel = new ChatGoogleGenerativeAI({
    model: "gemini-3-pro-preview",
    apiKey: process.env.GEMINI_API_KEY,
    temperature: 0.7,
});

// Route 1: Chat Endpoint (Existing)
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
                else messages.push(new AIMessage(msg.content));
            });
        }

        messages.push(new HumanMessage(message));

        const response = await chatModel.invoke(messages);

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

// Route 2: HealthKarma Analysis Endpoint (New)
router.post('/analyze', async (req, res) => {
    try {
        if (!process.env.GEMINI_API_KEY) {
            throw new Error("Gemini API Key not set");
        }

        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        // Use gemini-1.5-flash for better speed and reliability
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        const prompt = `
        You are a professional medical AI assistant. Analyze the following lifestyle and health data from a user survey:
        ${JSON.stringify(req.body.responses)}

        Analyze this data and return a JSON object with the following structure:
        {
          "score": number (0-100),
          "riskLevels": {
            "cholesterol": "Low" | "Medium" | "High",
            "cardiovascular": "Low" | "Medium" | "High",
            "diabetes": "Low" | "Medium" | "High",
            "hypertension": "Low" | "Medium" | "High",
            "lifestyle_risk": "Low" | "Medium" | "High"
          },
          "explanations": {
            "cholesterol": ["reason 1", "reason 2"],
            "cardiovascular": ["reason 1"],
            "diabetes": ["reason 1"],
            "hypertension": ["reason 1"],
            "lifestyle_risk": ["reason 1"]
          },
          "suggestions": ["action 1", "action 2", "action 3"]
        }

        Rules:
        - Do NOT provide clinical diagnoses.
        - Provide preventive healthcare guidance only.
        - Be supportive and clear.
        - Return ONLY the JSON object, do NOT wrap it in markdown code blocks.
        `;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        // Robust JSON extraction
        let jsonStr = text;
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            jsonStr = jsonMatch[0];
        }

        let data;
        try {
            data = JSON.parse(jsonStr);
        } catch (e) {
            console.error("JSON Parse Error:", e);
            console.error("Raw Text:", text);
            // Fallback text if JSON fails
            return res.status(500).json({
                message: 'Failed to parse AI response',
                raw: text
            });
        }

        res.json(data);
    } catch (err) {
        console.error("AI Analysis Error Detail:", err);
        // Check for specific API errors
        if (err.message && err.message.includes('API key')) {
            return res.status(500).json({ message: 'Invalid or missing API Key', error: err.message });
        }
        res.status(500).json({ message: 'AI Analysis failed', error: err.message });
    }
});

module.exports = router;
