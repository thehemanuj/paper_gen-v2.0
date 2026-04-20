import 'dart:async';
import 'package:flutter/material.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:paper_gen/screens/authentication/ScoreScreen.dart';
import 'package:provider/provider.dart';

import '../../ProviderData/ProgressData.dart';
import '../../ProviderData/QuestionData.dart';
import '../../assets/HelperClasses.dart';

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
  Timer? _timer;
  int _remainingSeconds = 0;

  GeneratedPaper? _paper;

  GeneratedPaper? _getPaper() {
    final questionData = Provider.of<QuestionData>(context, listen: false);
    return questionData.currentGeneratedPaper;
  }

  @override
  void initState() {
    super.initState();
    final qData = Provider.of<QuestionData>(context, listen: false);
    if (qData.timerEnabled) {
      _remainingSeconds = qData.timerSeconds *
          (qData.currentGeneratedPaper?.totalQuestions ?? 0);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _checkCorrect();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ProgressData>(context).darkMode;
    final textColor = darkMode ? Colors.white : Colors.black;
    final qData = Provider.of<QuestionData>(context);

    _paper = _getPaper();

    if (_paper == null || _paper!.subjects.isEmpty) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('images/papergen_border_up.png'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'No Questions to Display here',
                  style: TextStyle(color: textColor, fontSize: 25.0),
                ),
                SizedBox(height: 10.0),
                MyButton("Go Back", () => Navigator.pop(context), 0.3),
              ],
            ),
            Image.asset('images/papergen_border_down.png'),
          ],
        ),
      );
    }

    final currentSubject = _paper!.subjects[currentSubjectIndex];
    final currentQuestion = currentSubject.questions[currentQuestionIndex];
    final totalInSubject = currentSubject.questions.length;
    final attempted = qData.attempted;

    return Scaffold(
      backgroundColor: darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
        child: FloatingActionButton(
          backgroundColor: Color(0xff26A69A),
          onPressed: () =>
              Provider.of<ProgressData>(context, listen: false).setDarkMode(),
          child: Icon(
            darkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('images/papergen_border_up.png'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentSubject.subject} - ${currentSubject.difficulty}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    fontFamily: 'Copper',
                  ),
                ),
                if (qData.timerEnabled)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xff26a69a).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Color(0xff26a69a)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: Color(0xff26a69a), size: 18),
                        SizedBox(width: 5),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Text(
              'Q ${currentQuestionIndex + 1}/$totalInSubject',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      color: darkMode ? Color(0xff6e7286) : null,
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          currentQuestion.question,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2,
                        ),
                        itemCount: currentQuestion.options?.length ?? 0,
                        itemBuilder: (context, index) {
                          final option = currentQuestion.options![index];
                          final isSelected = selectedAnswer == option ||
                              index == attempted[currentQuestionIndex];

                          return InkWell(
                            overlayColor:
                                WidgetStatePropertyAll(Colors.transparent),
                            onTap: () {
                              setState(() {
                                selectedAnswer = option;
                                showExplanation = false;
                                Provider.of<QuestionData>(context,
                                        listen: false)
                                    .setAttempted(currentQuestionIndex, index);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xff26a69a)
                                      : Colors.grey,
                                  width: isSelected ? 4 : 1,
                                ),
                                borderRadius: BorderRadius.circular(200),
                                color: isSelected
                                    ? Color(0x3026a69a)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style:
                                      TextStyle(color: textColor, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xff26a69a), width: 2.0),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23.0),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            childrenPadding: EdgeInsets.all(16),
                            backgroundColor: Colors.transparent,
                            collapsedBackgroundColor: Colors.transparent,
                            onExpansionChanged: (isExpanded) {
                              if (isExpanded) {
                                bool deducted = Provider.of<QuestionData>(
                                        context,
                                        listen: false)
                                    .deductCoins(10);
                                if (!deducted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Not enough coins to view solution!")),
                                  );
                                }
                              }
                            },
                            title: Text(
                              'Solution (Costs 10 Coins)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff26a69a),
                              ),
                            ),
                            leading: Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xff26a69a),
                            ),
                            iconColor: Color(0xff26a69a),
                            collapsedIconColor: Color(0xff26a69a),
                            children: [
                              Text(
                                currentQuestion.explanation ??
                                    'No hint available',
                                style:
                                    TextStyle(fontSize: 14, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: _canGoPrevious()
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.end,
                      children: [
                        if (_canGoPrevious())
                          MyButton("Previous", _goToPrevious, 0.4),
                        if (_canGoNext()) MyButton("Next", _goToNext, 0.4),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, bottom: 50.0, top: 12.0, right: 12.0),
                    child: MyButton("Submit", () {
                      _checkCorrect();
                    }, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoPrevious() {
    if (_paper == null) return false;
    return currentQuestionIndex > 0 || currentSubjectIndex > 0;
  }

  bool _canGoNext() {
    if (_paper == null) return false;
    final currentSubject = _paper!.subjects[currentSubjectIndex];
    return currentQuestionIndex < currentSubject.questions.length - 1 ||
        currentSubjectIndex < _paper!.subjects.length - 1;
  }

  void _goToPrevious() {
    if (_paper == null) return;
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      } else if (currentSubjectIndex > 0) {
        currentSubjectIndex--;
        currentQuestionIndex =
            _paper!.subjects[currentSubjectIndex].questions.length - 1;
      }
      selectedAnswer = null;
      showExplanation = false;
    });
    Provider.of<QuestionData>(context, listen: false)
        .setViewed(currentQuestionIndex);
  }

  void _goToNext() {
    if (_paper == null) return;
    final currentSubject = _paper!.subjects[currentSubjectIndex];
    setState(() {
      if (currentQuestionIndex < currentSubject.questions.length - 1) {
        currentQuestionIndex++;
      } else if (currentSubjectIndex < _paper!.subjects.length - 1) {
        currentSubjectIndex++;
        currentQuestionIndex = 0;
      }
      selectedAnswer = null;
      showExplanation = false;
    });
    Provider.of<QuestionData>(context, listen: false)
        .setViewed(currentQuestionIndex);
  }

  void _checkCorrect() {
    _timer?.cancel();
    final provider = Provider.of<QuestionData>(context, listen: false);
    final attempted = provider.attempted;

    attempted.forEach((key, value) {
      final question = _paper!.subjects[currentSubjectIndex].questions[key];
      if (question.answer == question.options?[value]) {
        provider.setCorrect();
      } else {
        provider.setTotalQuestionsIncorrect();
      }
    });

    provider.saveMetricsToFirebase(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ScoreScreen(0)),
    );
  }
}
