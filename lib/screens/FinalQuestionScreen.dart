import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';

class DisplayQuestionsScreen extends StatefulWidget {
  const DisplayQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<DisplayQuestionsScreen> createState() => _DisplayQuestionsScreenState();
}

class _DisplayQuestionsScreenState extends State<DisplayQuestionsScreen> {
  int currentQuestionIndex = 0;
  int currentSubjectIndex = 0;
  String? selectedAnswer;
  bool showExplanation = false;

  @override
  Widget build(BuildContext context) {
    final questionData = Provider.of<QuestionData>(context);
    final paper = questionData.currentGeneratedPaper;

    // If no paper is generated
    if (paper == null || paper.subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Questions')),
        body: Center(
          child: Text('No questions available'),
        ),
      );
    }

    final currentSubject = paper.subjects[currentSubjectIndex];
    final currentQuestion = currentSubject.questions[currentQuestionIndex];
    final totalInSubject = currentSubject.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentSubject.subject} - ${currentSubject.difficulty}'),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Q ${currentQuestionIndex + 1}/$totalInSubject',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  currentQuestion.question,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Options (if available)
            if (currentQuestion.options != null &&
                currentQuestion.options!.isNotEmpty)
              ...currentQuestion.options!.map((option) {
                final isSelected = selectedAnswer == option;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedAnswer = option;
                        showExplanation = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }),

            // Check Answer Button
            if (selectedAnswer != null && !showExplanation)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showExplanation = true;
                    if (selectedAnswer == currentQuestion.answer) {
                      questionData.setCorrect();
                    }
                    questionData.setTotalQuestionsAttempted();
                  });
                },
                child: Text('Check Answer'),
              ),

            // Answer & Explanation
            if (showExplanation) ...[
              SizedBox(height: 16),
              Card(
                color: selectedAnswer == currentQuestion.answer
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedAnswer == currentQuestion.answer
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: selectedAnswer == currentQuestion.answer
                                ? Colors.green
                                : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            selectedAnswer == currentQuestion.answer
                                ? 'Correct!'
                                : 'Incorrect',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: selectedAnswer == currentQuestion.answer
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Answer: ${currentQuestion.answer}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        currentQuestion.explanation ?? 'Not Available',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Navigation Buttons
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                ElevatedButton.icon(
                  onPressed: _canGoPrevious() ? () => _goToPrevious() : null,
                  icon: Icon(Icons.arrow_back),
                  label: Text('Previous'),
                ),

                // Next Button
                ElevatedButton.icon(
                  onPressed: _canGoNext() ? () => _goToNext() : null,
                  icon: Icon(Icons.arrow_forward),
                  label: Text('Next'),
                ),
              ],
            ),

            // Subject Navigation
            SizedBox(height: 16),
            Text(
              'Subjects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: paper.subjects.asMap().entries.map((entry) {
                final idx = entry.key;
                final subject = entry.value;
                final isActive = idx == currentSubjectIndex;
                return ChoiceChip(
                  label:
                      Text('${subject.subject} (${subject.questions.length})'),
                  selected: isActive,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        currentSubjectIndex = idx;
                        currentQuestionIndex = 0;
                        selectedAnswer = null;
                        showExplanation = false;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  bool _canGoPrevious() {
    return currentQuestionIndex > 0 || currentSubjectIndex > 0;
  }

  bool _canGoNext() {
    final paper = Provider.of<QuestionData>(context, listen: false)
        .currentGeneratedPaper!;
    final currentSubject = paper.subjects[currentSubjectIndex];

    return currentQuestionIndex < currentSubject.questions.length - 1 ||
        currentSubjectIndex < paper.subjects.length - 1;
  }

  void _goToPrevious() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      } else if (currentSubjectIndex > 0) {
        currentSubjectIndex--;
        currentQuestionIndex = Provider.of<QuestionData>(context, listen: false)
                .currentGeneratedPaper!
                .subjects[currentSubjectIndex]
                .questions
                .length -
            1;
      }
      selectedAnswer = null;
      showExplanation = false;
    });
  }

  void _goToNext() {
    final paper = Provider.of<QuestionData>(context, listen: false)
        .currentGeneratedPaper!;
    final currentSubject = paper.subjects[currentSubjectIndex];

    setState(() {
      if (currentQuestionIndex < currentSubject.questions.length - 1) {
        currentQuestionIndex++;
      } else if (currentSubjectIndex < paper.subjects.length - 1) {
        currentSubjectIndex++;
        currentQuestionIndex = 0;
      }
      selectedAnswer = null;
      showExplanation = false;
    });
  }
}
