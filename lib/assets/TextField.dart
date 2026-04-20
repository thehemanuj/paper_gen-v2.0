import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ProviderData/ProgressData.dart';

class MyTextField extends StatefulWidget {
  final String hint;
  final Function(String) variable;
  final TextEditingController? controller;

  const MyTextField(this.hint, this.variable, this.controller, {super.key});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool obscureText = false;

  @override
  void initState() {
    super.initState();
    obscureText =
        widget.hint == 'Password' || widget.hint == 'Confirm Password';
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ProgressData>(context).darkMode;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF26a69a), Color(0xFF36d0c2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: darkMode ? const Color(0xFF0A0E27) : const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: obscureText,
            obscuringCharacter: '*',
            onChanged: widget.variable,
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
              fontFamily: 'funnel',
            ),
            cursorColor: const Color(0xFF26a69a),
            decoration: InputDecoration(
              suffixIcon: _buildSuffixIcon(),
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: darkMode ? Colors.white54 : Colors.black54,
                fontFamily: 'funnel',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    final isPasswordField =
        widget.hint == 'Password' || widget.hint == 'Confirm Password';
    if (!isPasswordField) return null;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: IconButton(
        style: const ButtonStyle(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        onPressed: () {
          setState(() {
            obscureText = false;
          });
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              obscureText = true;
            });
          });
        },
        icon: const Icon(Icons.remove_red_eye_outlined),
        color: const Color(0xff26a69a),
      ),
    );
  }
}
