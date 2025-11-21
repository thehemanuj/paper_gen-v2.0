import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:provider/provider.dart';

class MyPreferenceBox extends StatelessWidget {
  const MyPreferenceBox(this.widget, {super.key});

  final widget;
  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ProgressData>(context).darkMode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xff0A0E27) : const Color(0xffFDFBF7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkMode ? Colors.white60 : Colors.black45,
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: widget,
    );
  }
}

class MyCard extends StatelessWidget {
  const MyCard(this.title, this.subtitle, this.icon, this.function, this.widget,
      {super.key});
  final title, subtitle, icon, function, widget;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Color(0xff26a69a), fontFamily: 'Copper'),
      ),
      subtitle: Text(subtitle,
          style: TextStyle(color: Color(0xff26a69a), fontFamily: 'Copper')),
      leading: Icon(
        icon,
        color: Color(0xff26a69a),
      ),
      trailing: widget,
    );
  }
}
