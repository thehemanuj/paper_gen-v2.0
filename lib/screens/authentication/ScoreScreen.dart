import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:provider/provider.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen(this.form, {super.key});

  final form;

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
                      form == 0 ? 'Score' : 'Progress',
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
                          if (form == 0)
                            buildRow("Correct", qd.correctLocal, null, false,
                                textColor),
                          if (form == 0)
                            buildRow("Attempted", qd.attempted.length, null,
                                false, textColor),
                          if (form == 0)
                            buildRow("Viewed", qd.viewed.length, null, false,
                                textColor),
                          if (form == 0)
                            buildRow("Accuracy", qd.correctLocal,
                                qd.attempted.length, true, textColor),
                          if (form == 0)
                            buildRow(
                                "Score",
                                qd.correctLocal,
                                qd.currentGeneratedPaper?.subjects[0].questions
                                        .length ??
                                    0,
                                false,
                                textColor),
                          buildRow("Lifetime Correct", qd.totalQuestionsCorrect,
                              null, false, textColor),
                          buildRow(
                              "Lifetime Attempted",
                              qd.totalQuestionsAttempted,
                              null,
                              false,
                              textColor),
                          buildRow("Total Viewed", qd.totalQuestionsViewed,
                              null, false, textColor),
                          buildRow(
                              "Lifetime Generated",
                              qd.totalQuestionsGenerated,
                              null,
                              false,
                              textColor),
                          buildRow(
                              "Lifetime Accuracy",
                              qd.totalQuestionsCorrect,
                              qd.totalQuestionsAttempted,
                              true,
                              textColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child:
                    MyButton(form == 0 ? "End Assessment" : "Close Screen", () {
                  if (form == 0) {
                    qd.saveMetricsToFirebase(context);
                    qd.resetData();
                  }
                  Navigator.pop(context);
                }, 1),
              )
            ],
          ),
        );
      },
    );
  }

  TableRow buildRow(
    String label,
    dynamic param1,
    dynamic param2,
    bool isPercent,
    Color colour,
  ) {
    String valueText;

    if (isPercent && param2 != null) {
      double percent = (param2 != 0) ? (param1 / param2) * 100 : 0.0;
      valueText = "${percent.toStringAsFixed(2)}%";
    } else if (!isPercent && param2 != null) {
      valueText = "$param1/$param2";
    } else {
      valueText = param1.toString();
    }

    return TableRow(children: [
      MyText(label, 22.0, colour, 'left'),
      MyText(valueText, 22.0, colour, 'right'),
    ]);
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
