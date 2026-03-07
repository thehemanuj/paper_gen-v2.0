import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:provider/provider.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var textColor = Provider.of<ProgressData>(context).darkMode
        ? Colors.white
        : Colors.black;
    return Consumer2<ProgressData, QuestionData>(
      builder: (context, ProgressData proData, QuestionData qd, child) {
        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: FloatingActionButton(
              backgroundColor: Color(0xff26A69A),
              onPressed: () {
                Provider.of<ProgressData>(context, listen: false).setDarkMode();
              },
              child: Icon(
                proData.darkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor:
              proData.darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(proData.darkMode
                  ? 'images/papergen_bg2_dark.png'
                  : 'images/papergen_bg2_light.png'),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 30.0,
                          fontFamily: 'Copper',
                          decoration: TextDecoration.underline),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3), // label column
                          1: FlexColumnWidth(1), // value column
                        },
                        children: [
                          TableRow(children: [
                            MyText(
                              "Correct",
                              22.0,
                              textColor,
                              'left',
                            ),
                            MyText(
                                "${qd.correctLocal}", 22.0, textColor, 'right'),
                          ]),
                          TableRow(children: [
                            MyText(
                              "Attempted",
                              22.0,
                              textColor,
                              'left',
                            ),
                            MyText("${qd.attempted.length}", 22.0, textColor,
                                'right'),
                          ]),
                          TableRow(children: [
                            MyText(
                              "Viewed",
                              22.0,
                              textColor,
                              'left',
                            ),
                            MyText("${qd.viewed.length}", 22.0, textColor,
                                'right'),
                          ]),
                          TableRow(children: [
                            MyText(
                              "Accuracy",
                              22.0,
                              textColor,
                              'left',
                            ),
                            MyText(
                                "${(qd.correctLocal / qd.attempted.length * 100).toStringAsFixed(2)}%",
                                22.0,
                                textColor,
                                'right'),
                          ]),
                          TableRow(children: [
                            MyText(
                              "Score",
                              22.0,
                              textColor,
                              'left',
                            ),
                            MyText(
                                "${qd.correctLocal}/${qd.currentGeneratedPaper?.subjects[0].questions.length}",
                                22.0,
                                textColor,
                                'right'),
                          ]),
                          TableRow(children: [
                            MyText(
                              "Lifetime Correct",
                              22.0,
                              textColor,
                              'left',
                            ),
                            MyText("${qd.totalQuestionsCorrect}", 22.0,
                                textColor, 'right'),
                          ]),
                          TableRow(children: [
                            MyText(
                              "Lifetime Accuracy",
                              22.0,
                              textColor,
                              'left',
                            ),
                            MyText(
                                "${(qd.totalQuestionsCorrect / qd.totalQuestionsAttempted * 100).toStringAsFixed(2)}%",
                                22.0,
                                textColor,
                                'right'),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: MyButton("End Assessment", () {
                  qd.saveMetricsToFirebase(context);
                  qd.resetData();
                  Navigator.pop(context);
                }, 1),
              )
            ],
          ),
        );
      },
    );
  }
}

class MyText extends StatelessWidget {
  const MyText(this.string, this.width, this.color, this.align, {super.key});
  final string;
  final width;
  final color;
  final align;
  @override
  Widget build(BuildContext context) {
    return Text(string,
        style: TextStyle(color: color, fontSize: width, fontFamily: 'Copper'),
        textAlign: align == 'left' ? TextAlign.left : TextAlign.right);
  }
}

// "${(qd.correct / 1 * 100).toStringAsFixed(1)}%"
