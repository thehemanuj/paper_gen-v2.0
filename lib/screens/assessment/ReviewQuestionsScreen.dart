import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import '../../assets/HelperClasses.dart';
import 'package:provider/provider.dart';

class ReviewQuestionsScreen extends StatelessWidget {
  final GeneratedPaper? paperOverride;
  final Map<int, int>? answersOverride;

  const ReviewQuestionsScreen({Key? key, this.paperOverride, this.answersOverride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qData = Provider.of<QuestionData>(context);
    final proData = Provider.of<ProgressData>(context);
    final darkMode = proData.darkMode;
    final textColor = darkMode ? Colors.white : Colors.black;
    
    final paper = paperOverride ?? qData.currentGeneratedPaper;
    final userAnswers = answersOverride ?? qData.attempted;

    if (paper == null || paper.subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review', style: TextStyle(fontFamily: 'Copper'))),
        body: const Center(child: Text('No results to review.')),
      );
    }

    return Scaffold(
      backgroundColor: darkMode ? const Color(0xff0A0E27) : const Color(0xffFDFBF7),
      appBar: AppBar(
        title: const Text('Review Answers', style: TextStyle(fontFamily: 'Copper')),
        backgroundColor: const Color(0xff26a69a),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: paper.subjects[0].questions.length,
        itemBuilder: (context, index) {
          final question = paper.subjects[0].questions[index];
          final userSelectedIndex = userAnswers[index];
          String userSelectedAnswer = "Not Attempted";
          if (userSelectedIndex != null &&
              question.options != null &&
              userSelectedIndex < question.options!.length) {
            userSelectedAnswer = question.options![userSelectedIndex];
          }
          final isCorrect = userSelectedAnswer == question.answer;

          return Card(
            color: darkMode ? const Color(0xff1A1F38) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 15),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style: TextStyle(
                      color: const Color(0xff26a69a),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Copper'
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.question,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                  const SizedBox(height: 15),
                  _buildAnswerRow('Your Answer: ', userSelectedAnswer, isCorrect ? Colors.green : Colors.red, textColor),
                  const SizedBox(height: 5),
                  if (!isCorrect)
                    _buildAnswerRow('Correct Answer: ', question.answer ?? '', Colors.green, textColor),
                  const SizedBox(height: 10),
                  Divider(color: textColor.withOpacity(0.1)),
                  Text(
                    'Explanation:',
                    style: TextStyle(color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    question.explanation ?? 'No explanation provided.',
                    style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerRow(String label, String value, Color color, Color textColor) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        if (color == Colors.green) const Icon(Icons.check_circle, color: Colors.green, size: 20),
        if (color == Colors.red) const Icon(Icons.cancel, color: Colors.red, size: 20),
      ],
    );
  }
}
