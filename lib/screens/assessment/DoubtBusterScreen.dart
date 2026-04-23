import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:provider/provider.dart';

class DoubtBusterScreen extends StatefulWidget {
  final String question;
  final String correctAnswer;
  final String explanation;

  const DoubtBusterScreen({
    Key? key,
    required this.question,
    required this.correctAnswer,
    required this.explanation,
  }) : super(key: key);

  @override
  State<DoubtBusterScreen> createState() => _DoubtBusterScreenState();
}

class _DoubtBusterScreenState extends State<DoubtBusterScreen> {
  final TextEditingController _doubtController = TextEditingController();
  String _aiResponse = '';
  bool _isLoading = false;

  void _askAI() async {
    if (_doubtController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _aiResponse = '';
    });

    final qData = Provider.of<QuestionData>(context, listen: false);
    final response = await qData.askAIDoubt(
      widget.question,
      widget.correctAnswer,
      widget.explanation,
      _doubtController.text.trim(),
    );

    setState(() {
      _aiResponse = response ?? "Couldn't get a response. Please try again.";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ProgressData>(context).darkMode;
    final textColor = darkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: darkMode ? const Color(0xff0A0E27) : const Color(0xffFDFBF7),
      appBar: AppBar(
        title: const Text('AI Study Buddy', style: TextStyle(fontFamily: 'Copper')),
        backgroundColor: const Color(0xff26a69a),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: darkMode ? Colors.white10 : Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Question:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 5),
                  Text(widget.question, style: TextStyle(color: textColor.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "What's your doubt?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Copper',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _doubtController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "e.g., Why is it x^2 and not 2x?",
                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                filled: true,
                fillColor: darkMode ? Colors.white10 : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xff26a69a), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _askAI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff26a69a),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Explain This to Me 🚀', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            if (_aiResponse.isNotEmpty) ...[
              const SizedBox(height: 30),
              Text(
                'AI Response:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Copper',
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xff26a69a).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xff26a69a).withOpacity(0.3)),
                ),
                child: Text(
                  _aiResponse,
                  style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
