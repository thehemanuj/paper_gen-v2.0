import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ProviderData/ProgressData.dart';

class MyCustomPastPaper extends StatelessWidget {
  MyCustomPastPaper(
      this.title, this.numberOfQuestions, this.createdAt, this.onTap,
      {this.color = const Color(0xff26A69A), super.key});
  final onTap, title, numberOfQuestions, createdAt, color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Provider.of<ProgressData>(context).darkMode
                  ? Color(0xff0A0E27)
                  : Color(0xffFDFBF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Color(0xff26A69A),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            color: color, fontSize: 25.0, fontFamily: 'Copper'),
                      ),
                      Text(
                        "$numberOfQuestions Questions",
                        style: TextStyle(
                            color: color, fontSize: 20.0, fontFamily: 'Copper'),
                      )
                    ],
                  ),
                  Text("Created At : $createdAt")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
