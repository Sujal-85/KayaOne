import 'dart:convert';
import 'dart:async';
import 'dart:ui'; // Added for Glassmorphism
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kayaone/core/api_config.dart';
import 'package:kayaone/presentation/booking/booking_success_screen.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiBookingScreen extends StatefulWidget {
  const AiBookingScreen({super.key});

  @override
  State<AiBookingScreen> createState() => _AiBookingScreenState();
}

class _AiBookingScreenState extends State<AiBookingScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  // Gemini
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _isGeminiLoading = false;

  bool _isListening = false;
  final String _text = 'Press the mic and start speaking...';
  final List<ChatMessage> _messages = [];
  String _currentLanguage = 'en-US';
  bool _hasSelectedLanguage = false; // Language Check
  List<String> _quickReplies = []; // For Quick Reply Chips
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initTts();
    // _initGemini(); // Lazy init after language selection
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _speech.stop();
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  void _initGemini() {
    _model = GenerativeModel(
      model: 'gemini-3-pro-preview',
      apiKey: ApiConfig.geminiApiKey,
      generationConfig: GenerationConfig(temperature: 0.3),
      systemInstruction: Content.text(
          "You are KayaOne AI, the FASTEST medical booking assistant. "
          "GOAL: Book a Doctor or a Blood Collection Slot in < 3 interactions. "
          "DATA NEEDED: 1. Service Type (Doctor/Blood Collection) 2. Specification (Cardio/Full Body Checkup) 3. Time (Morning/Evening). "
          "RULES: "
          "- Use **BOLD** for key details (e.g. **Doctor**, **Tomorrow**, **Blood Slot**). "
          "- Keep questions extremely short. "
          "- Assume 'Today' or 'Tomorrow' if not specified, just ask to confirm. "
          "- If details are sufficient, IMMEDIATELY generate specific JSON. order: details -> JSON. "
          "- JSON FORMAT: |||json { \"type\": \"confirm_card\", \"booking_type\": \"doctor\", \"title\": \"Dr. Anjali Desai\", \"subtitle\": \"Senior Cardiologist\", \"time\": \"Tomorrow, 10:00 AM\", \"fee\": \"₹800\" } ||| "
          "- For Blood Slot (ALWAYS FREE): |||json { \"type\": \"confirm_card\", \"booking_type\": \"lab\", \"title\": \"Blood Collection Slot\", \"subtitle\": \"Home Collection\", \"time\": \"Tomorrow, 07:00 AM\", \"fee\": \"₹0\" } ||| "
          "- To suggest quick replies (e.g. Doctor, Blood Slot, Morning, Evening), append: |||replies [\"Option1\", \"Option2\"]||| "
          "- Reply in user's language."),
    );

    _chat = _model.startChat();
  }

  void _onLanguageSelected(String langCode, String langName) {
    _initGemini(); // Init Gemini after language is known (optional, but good for cleanliness)
    setState(() {
      _currentLanguage = langCode;
      _hasSelectedLanguage = true;
    });

    // Set TTS Language
    if (langCode == 'hi-IN') {
      _flutterTts.setLanguage('hi-IN');
    } else if (langCode == 'mr-IN') {
      _flutterTts.setLanguage('hi-IN');
    } else {
      _flutterTts.setLanguage('en-US');
    }

    String greeting =
        "Hello! I'm KayaOne AI. Need a Doctor or a Blood Collection Slot?";
    if (langCode == 'hi-IN') {
      greeting =
          "नमस्ते! मैं कायावन एआई हूँ। क्या आपको डॉक्टर या ब्लड कलेक्शन स्लॉट की आवश्यकता है?";
    }
    if (langCode == 'mr-IN') {
      greeting =
          "नमस्कार! मी कायावन एआई आहे. तुम्हाला डॉक्टर किंवा ब्लड कलेक्शन स्लॉटची गरज आहे का?";
    }

    _addMessage(
        ChatMessage(text: greeting, isUser: false, type: ChatMessageType.text));
    _speak(greeting);

    setState(() {
      _quickReplies = [
        "Doctor",
        "Blood Slot",
        "Health Karma AI",
        "Health Assistant AI"
      ];
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
            // Don't auto-send, let user review text in controller
          }
        },
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            _textController.text = val.recognizedWords;
            // Move cursor to end
            _textController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textController.text.length));
          },
          localeId: _currentLanguage,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _addMessage(ChatMessage msg) {
    if (mounted) {
      setState(() {
        _messages.add(msg);
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _speak(String text) async {
    // Basic language detection or use selected
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      await _flutterTts.setLanguage('hi-IN');
    } else {
      await _flutterTts.setLanguage('en-US');
    }
    await _flutterTts.speak(text);
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    _processUserBuffer(text);
  }

  void _processUserBuffer(String userText) {
    if (userText.isEmpty) return;

    _addMessage(
        ChatMessage(text: userText, isUser: true, type: ChatMessageType.text));
    setState(() {
      _isGeminiLoading = true;
    });

    _processWithGemini(userText);
  }

  Future<void> _processWithGemini(String input) async {
    try {
      final response = await _chat.sendMessage(Content.text(input));
      final text = response.text ?? "Sorry, I didn't verify that.";

      Map<String, dynamic>? cardData;
      String cleanText = text;

      // Extract JSON
      final jsonRegex = RegExp(r'\|\|\|json(.*?)\|\|\|', dotAll: true);
      final jsonMatch = jsonRegex.firstMatch(text);
      if (jsonMatch != null) {
        try {
          String jsonStr = jsonMatch.group(1)!.trim();
          cardData = jsonDecode(jsonStr);
          cleanText = text.replaceFirst(jsonMatch.group(0)!, '').trim();
        } catch (e) {
          debugPrint("JSON Error: $e");
        }
      }

      // Extract Quick Replies
      final repliesRegex = RegExp(r'\|\|\|replies(.*?)\|\|\|', dotAll: true);
      final repliesMatch = repliesRegex.firstMatch(cleanText);
      if (repliesMatch != null) {
        try {
          String repliesStr = repliesMatch.group(1)!.trim();
          List<dynamic> repliesJson = jsonDecode(repliesStr);
          setState(() {
            _quickReplies = repliesJson.map((e) => e.toString()).toList();
          });
          cleanText = cleanText.replaceFirst(repliesMatch.group(0)!, '').trim();
        } catch (e) {
          debugPrint("Replies Error: $e");
        }
      } else {
        setState(() => _quickReplies = []);
      }

      _addMessage(ChatMessage(
          text: cleanText,
          isUser: false,
          type: cardData != null ? ChatMessageType.card : ChatMessageType.text,
          data: cardData));

      // Speak text (remove markdown for speech)
      _speak(cleanText.replaceAll('*', ''));
    } catch (e) {
      _addMessage(ChatMessage(
          text: "I'm having trouble connecting. Please try again.",
          isUser: false,
          type: ChatMessageType.text));
    } finally {
      if (mounted) {
        setState(() => _isGeminiLoading = false);
      }
    }
  }

  void _handleConfirmBooking(Map<String, dynamic> data) async {
    if (data['booking_type'] == 'lab') {
      data['fee'] = '₹0';
    }

    // Simulate booking delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Navigate to Success
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.type == ChatMessageType.card && msg.data != null) {
      final isDoctor = msg.data!['booking_type'] == 'doctor';
      final gradient = isDoctor
          ? [const Color(0xFF6B4BCC), const Color(0xFF4A329A)]
          : [const Color(0xFF2E8B57), const Color(0xFF1E5C39)];

      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                        msg.data!['booking_type'] == 'doctor'
                            ? Icons.medical_services
                            : Icons.science,
                        color: Colors.white70,
                        size: 20),
                    const SizedBox(width: 8),
                    Text("Confirm Details",
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(msg.data!['title'] ?? 'Service',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(msg.data!['subtitle'] ?? '',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                Text("Time: ${msg.data!['time']}",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text("Fee: ${msg.data!['fee']}",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleConfirmBooking(msg.data!),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: msg.data!['booking_type'] == 'doctor'
                            ? const Color(0xFF4A329A)
                            : const Color(0xFF1E5C39),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text("Confirm Booking",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    // REGULAR TEXT MESSAGES
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI AVATAR
          if (!msg.isUser)
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 38, // Slightly bigger
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 6)
                ],
                border: Border.all(color: Colors.white, width: 2),
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/images/logo.png'), // Using logo as bot avatar
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // MESSAGE BUBBLE
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppTheme.primaryGreen
                    : Colors.white, // White bubble for AI
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(msg.isUser ? 20 : 4),
                  topRight: Radius.circular(msg.isUser ? 4 : 20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                boxShadow: [
                  if (!msg.isUser)
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                ],
              ),
              child: msg.isUser
                  ? Text(
                      msg.text,
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    )
                  : MarkdownBody(
                      data: msg.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.outfit(
                            color: const Color(0xFF2D3142),
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500),
                        strong: GoogleFonts.outfit(
                            color: Colors.black, // Bold text darker
                            fontWeight: FontWeight.w700),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        title: Text("Medica AI",
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100), // Spacing for AppBar
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 20),
                            itemCount:
                                _messages.length + (_isGeminiLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _messages.length) {
                                return const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                  ),
                                );
                              }
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                        ),
                        _buildInputArea(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!_hasSelectedLanguage) _buildLanguageOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -5),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        children: [
          // Quick Replies
          if (_quickReplies.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(_quickReplies[index]),
                    onPressed: () {
                      if (_quickReplies[index].contains("Health")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${_quickReplies[index]} Coming Soon!",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: AppTheme.darkBlue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      _textController.text = _quickReplies[index];
                      _sendMessage();
                    },
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    labelStyle: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  );
                },
              ),
            ),
          if (_quickReplies.isNotEmpty) const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          autofocus: false, // User requested no auto-focus
                          decoration: InputDecoration(
                            hintText: "Type or speak...",
                            hintStyle: GoogleFonts.plusJakartaSans(
                                color: const Color.fromARGB(255, 63, 37, 37)),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder:
                                InputBorder.none, // Ensure no border shows
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isListening) {
                            // Stop
                            _listen();
                          } else {
                            // Start
                            _listen();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            _isListening
                                ? Icons.stop_circle_rounded
                                : Icons.mic_rounded,
                            color: _isListening
                                ? Colors.red
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Send Button
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded,
                      color: AppTheme.primaryGreen.withOpacity(0.1), size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select Language / भाषा चुनें",
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _langOption("English", "en-US"),
                const SizedBox(height: 12),
                _langOption("हिंदी (Hindi)", "hi-IN"),
                const SizedBox(height: 12),
                _langOption("मराठी (Marathi)", "mr-IN"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _langOption(String label, String code) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onLanguageSelected(code, label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          foregroundColor: AppTheme.primaryGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

enum ChatMessageType { text, card }

class ChatMessage {
  final String text;
  final bool isUser;
  final ChatMessageType type;
  final Map<String, dynamic>? data;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.type,
    this.data,
  });
}
