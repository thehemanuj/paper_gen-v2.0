import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ProviderData/ProgressData.dart';

class MyButton extends StatelessWidget {
  const MyButton(this.title, this.function, this.value, {super.key});
  final title, function, value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * value,
        height: 60,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xff26a69a)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          onPressed: function,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Provider.of<ProgressData>(context).darkMode
                      ? Colors.white
                      : Colors.black,
                  fontFamily: 'Copper',
                  fontSize: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}

class MyLogoutButton extends StatelessWidget {
  const MyLogoutButton(this.title, this.function, this.value, {super.key});
  final title, function, value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * value,
        height: 60,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xfffa1616)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          onPressed: function,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Provider.of<ProgressData>(context).darkMode
                      ? Colors.white
                      : Colors.black,
                  fontFamily: 'Copper',
                  fontSize: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}
