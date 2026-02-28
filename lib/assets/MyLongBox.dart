import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:provider/provider.dart';

class MyLongBox extends StatelessWidget {
  const MyLongBox(this.papersDone, this.count, this.total, this.subjects,
      this.metrics, this.function,
      {super.key});
  final papersDone, count, total, subjects, metrics, function;

  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ProgressData>(context).darkMode;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xff26A69A),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Papers Done
              Column(
                children: [
                  Text(
                    '$papersDone',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff26A69A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Papers Done',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkMode ? Colors.white54 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Average Score
              Column(
                children: [
                  Text(
                    '${total == 0 ? 0 : (count / total * 100).round()}%',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff26A69A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Avg Score',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkMode ? Colors.white54 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Subjects
              Column(
                children: [
                  Text(
                    '$subjects',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff26A69A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Subjects',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkMode ? Colors.white54 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          // Divider
          Divider(
            color: Color(0xff26A69A),
            thickness: 1,
          ),
          SizedBox(height: 12),
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    metrics >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: metrics >= 0 ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${metrics >= 0 ? '+' : '-'} ${metrics}% this week',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: function,
                child: Text(
                  'View Details →',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff26A69A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
