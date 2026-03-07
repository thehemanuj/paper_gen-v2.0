import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paper_gen/ProviderData/AuthorisationData.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:paper_gen/assets/TextField.dart';
import 'package:paper_gen/screens/WelcomeScreen.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildStep({
    required String title,
    String? subtitle,
    required List<Widget> fields,
    required List<Widget> buttons,
    required bool darkMode,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  color: darkMode ? Colors.white : Colors.black,
                  fontFamily: 'Copper',
                  fontSize: 30.0,
                )),
            if (subtitle != null)
              Text(subtitle,
                  style: TextStyle(
                    color: darkMode ? Colors.white : Colors.black,
                    fontFamily: 'Copper',
                    fontSize: 15.0,
                  )),
            ...fields,
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
      BuildContext context, AuthorisationData authData, bool darkMode) {
    switch (authData.registrationValue) {
      case 1:
        return _buildStep(
          title: "What Should I call you?",
          darkMode: darkMode,
          fields: [
            MyTextField('First Name', authData.setFN, authData.fnController),
            MyTextField('Last Name', authData.setLN, authData.lnController),
          ],
          buttons: [
            MyButton('Go Back to Login', () => Navigator.pop(context), 0.42),
            MyButton('Go Ahead', () {
              if (authData.fnController.text.trim().isEmpty ||
                  authData.lnController.text.trim().isEmpty) {
                return _showSnackBar(
                    context, 'Please enter both first and last name');
              }
              authData.setRegistration(1);
            }, 0.40),
          ],
        );

      case 2:
        return _buildStep(
          title: "What's your Email?",
          darkMode: darkMode,
          fields: [
            MyTextField('Email', authData.setEmail, authData.emailController),
          ],
          buttons: [
            MyButton('Back', () => authData.setRegistration(-1), 0.30),
            MyButton('Proceed', () {
              if (!_validateEmail(context, authData)) return;
              authData.setRegistration(1);
            }, 0.36),
          ],
        );

      case 3:
        return _buildStep(
          title: "Let's secure your account",
          subtitle: "We will ask this if you forget your password",
          darkMode: darkMode,
          fields: [
            MyTextField('Security Question', authData.setQuestion,
                authData.questionController),
            MyTextField(
                'Your answer', authData.setAnswer, authData.answerController),
          ],
          buttons: [
            MyButton('Back', () => authData.setRegistration(-1), 0.30),
            MyButton('Proceed', () {
              if (authData.questionController.text.trim().isEmpty ||
                  authData.answerController.text.trim().isEmpty) {
                return _showSnackBar(
                    context, 'Please enter both question and answer');
              }
              authData.setRegistration(1);
            }, 0.36),
          ],
        );

      case 4:
        return _buildStep(
          title: "Set Your Password!",
          darkMode: darkMode,
          fields: [
            MyTextField(
                'Password', authData.setPassword, authData.passwordController),
            MyTextField('Confirm Password', authData.setConfirmPassword,
                authData.confirmController),
          ],
          buttons: [
            MyButton('Back', () => authData.setRegistration(-1), 0.30),
            MyButton('Register', () {
              if (authData.passwordController.text.trim().isEmpty) {
                return _showSnackBar(context, 'Please enter a password');
              }
              if (authData.password != authData.confirmPassword) {
                return _showSnackBar(context, 'Passwords do not match');
              }
              authData.firebaseNewUserCreate(context);
            }, 0.36),
          ],
        );

      case 12:
        return _buildStep(
          title: "What's your Email?",
          darkMode: darkMode,
          fields: [
            MyTextField('Email', authData.setEmail, authData.emailController),
          ],
          buttons: [
            MyButton('Go Back To Login', () {
              authData.setRegistration(-(authData.registrationValue - 1));
              Navigator.pop(context);
            }, 0.42),
            MyButton('Proceed', () async {
              if (!_validateEmail(context, authData)) return;
              await authData.fetchFirebaseData(context);
              if (authData.answer != '') {
                authData.setRegistration(1);
              } else {
                _showSnackBar(context, 'Create your new Account');
              }
            }, 0.30),
          ],
        );

      case 13:
        return _buildStep(
          title: authData.question,
          darkMode: darkMode,
          fields: [
            MyTextField('Answer', authData.setEnteredAnswer,
                authData.enteredAnswerController),
          ],
          buttons: [
            MyButton('Back', () => authData.setRegistration(-1), 0.40),
            MyButton('Proceed', () {
              if (authData.enteredAnswerController.text.trim().isEmpty) {
                return _showSnackBar(context, 'Please enter your answer');
              }
              if (authData.enteredAnswer.toLowerCase() ==
                  authData.answer.toLowerCase()) {
                Provider.of<QuestionData>(context, listen: false)
                    .getFirebaseDatabase(context);
                authData.resetPassword(context, authData.email);
                authData.setRegistration(-(authData.registrationValue - 1));
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => WelcomeScreen()));
              } else {
                _showSnackBar(context, 'Incorrect answer');
              }
            }, 0.30),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  bool _validateEmail(BuildContext context, AuthorisationData authData) {
    final email = authData.emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar(context, 'Please enter your email');
      return false;
    }
    if (!EmailValidator.validate(email)) {
      _showSnackBar(context, 'Please enter a valid email');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthorisationData, ProgressData>(
      builder: (context, authData, progressData, _) {
        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: FloatingActionButton(
              backgroundColor: const Color(0xff26A69A),
              onPressed: progressData.setDarkMode,
              child: Icon(
                progressData.darkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: progressData.darkMode
              ? const Color(0xff0A0E27)
              : const Color(0xffFDFBF7),
          body: ModalProgressHUD(
            progressIndicator:
                const CircularProgressIndicator(color: Color(0xff26A69A)),
            inAsyncCall: progressData.loading == 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('images/papergen_border_up.png'),
                _buildStepContent(context, authData, progressData.darkMode),
                Image.asset('images/papergen_border_down.png'),
              ],
            ),
          ),
        );
      },
    );
  }
}
