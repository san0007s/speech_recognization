import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize speech recognition: $e";
      });
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _wordsSpoken = '';
      _errorMessage = '';
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Error during speech recognition: $e";
      });
    } finally {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Speech Demo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _isListening
                  ? "Listening..."
                  : _speechEnabled
                  ? "Tap the microphone to start listening..."
                  : "Speech not available",
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              _wordsSpoken,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_isListening && _confidenceLevel > 0)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        tooltip: _isListening ? 'Stop' : 'Listen',
        child: Icon(_isListening ? Icons.stop : Icons.mic),
        backgroundColor: _isListening ? Colors.red : Colors.blue,
      ),
    );
  }
}
