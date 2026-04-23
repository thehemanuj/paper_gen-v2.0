import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:provider/provider.dart';

class ProgressInsights extends StatelessWidget {
  const ProgressInsights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qData = Provider.of<QuestionData>(context);
    final proData = Provider.of<ProgressData>(context);
    final darkMode = proData.darkMode;
    final textColor = darkMode ? Colors.white : Colors.black;

    // Calculate days remaining to exam
    int daysRemaining = -1;
    if (qData.examDate != null) {
      daysRemaining = qData.examDate!.difference(DateTime.now()).inDays;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Stats Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkMode ? const Color(0xff1A1F38) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xff26A69A), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatTile('$daysRemaining', 'Days to Exam', Icons.event, darkMode),
                  _buildStatTile('${qData.streak}', 'Day Streak', Icons.local_fire_department, darkMode, color: Colors.orange),
                  _buildStatTile('${qData.coins}', 'Coins', Icons.monetization_on, darkMode, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 20),
              // Accuracy Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Overall Accuracy', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('${qData.totalQuestionsAttempted == 0 ? 0 : (qData.totalQuestionsCorrect / qData.totalQuestionsAttempted * 100).toStringAsFixed(1)}%', 
                          style: const TextStyle(color: Color(0xff26A69A), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: qData.totalQuestionsAttempted == 0 ? 0 : (qData.totalQuestionsCorrect / qData.totalQuestionsAttempted),
                      backgroundColor: darkMode ? Colors.white10 : Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff26A69A)),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Subjects Attempted Chips
        if (qData.subjectsAttempted.isNotEmpty) ...[
          Text(
            'Proficiency Areas',
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Copper'),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: qData.subjectsAttempted.map((subject) {
              return Chip(
                label: Text(subject, style: const TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xff26A69A).withOpacity(0.1),
                side: const BorderSide(color: Color(0xff26A69A)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatTile(String value, String label, IconData icon, bool darkMode, {Color color = const Color(0xff26A69A)}) {
    final textColor = darkMode ? Colors.white : Colors.black;
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 5),
        Text(
          value == '-1' ? 'N/A' : value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.5), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
