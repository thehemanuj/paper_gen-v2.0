import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ProviderData/ProgressData.dart';

class MyBox extends StatelessWidget {
  MyBox(this.icon, this.title, this.number, this.onTap,
      {this.color = const Color(0xff26A69A), super.key});
  final onTap, title, number, icon, color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: color,
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff26A69A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
