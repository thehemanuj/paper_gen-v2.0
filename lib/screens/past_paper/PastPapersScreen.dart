import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:paper_gen/assets/Custom%20Box%20Design.dart';
import 'package:paper_gen/screens/past_paper/PastPapersQuestionScreen.dart';
import 'package:provider/provider.dart';

class PastPapersScreen extends StatelessWidget {
  const PastPapersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<ProgressData>(context, listen: false).darkMode;
    String processDate(dynamic cat) {
      DateTime parsedDate =
          cat is DateTime ? cat : DateTime.parse(cat.toString());

      int day = parsedDate.day;
      String month = DateFormat("MMMM").format(parsedDate);
      int year = parsedDate.year;

      String suffix;
      if (day >= 11 && day <= 13) {
        suffix = "th";
      } else {
        switch (day % 10) {
          case 1:
            suffix = "st";
            break;
          case 2:
            suffix = "nd";
            break;
          case 3:
            suffix = "rd";
            break;
          default:
            suffix = "th";
        }
      }

      String time = DateFormat("h:mm a").format(parsedDate);

      return "$day$suffix $month, $year at $time";
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xff0A0E27) : const Color(0xffFDFBF7),
      body: Consumer<QuestionData>(
        builder: (context, qData, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('images/papergen_border_up.png'),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Color(0xff26a69a)),
                      SizedBox(width: 8),
                      Text(
                        'Back',
                        style:
                            TextStyle(color: Color(0xff26a69a), fontSize: 25.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: qData.pastPapers.isNotEmpty
                    ? ListView.builder(
                        itemCount: qData.pastPapers.length,
                        itemBuilder: (context, index) {
                          final paper = qData.pastPapers[index];
                          return MyCustomPastPaper(
                              paper.subjects[0].subject,
                              paper.subjects[0].questions.length,
                              processDate(paper.createdAt), () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PastPapersQuestionScreen(
                                            paper.subjects[0].questions,
                                            isDarkMode)));
                          });
                        },
                      )
                    : Center(
                        child: Text(
                          'Nothing to Show',
                          style: const TextStyle(
                              color: Color(0xff26a69a), fontSize: 18),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
