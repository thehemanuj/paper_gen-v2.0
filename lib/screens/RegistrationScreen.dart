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

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthorisationData, ProgressData>(
      builder: (BuildContext context, authData, progressData, Widget? child) {
        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: FloatingActionButton(
              backgroundColor: Color(0xff26A69A),
              onPressed: () {
                progressData.setDarkMode();
              },
              child: Icon(
                progressData.darkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor:
              progressData.darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
          body: ModalProgressHUD(
            progressIndicator: CircularProgressIndicator(
              color: Color(0xff26A69A),
            ),
            inAsyncCall: progressData.loading == 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('images/papergen_border_up.png'),

                // ✅ Step 1: Name (registrationValue == 1)
                if (authData.registrationValue == 1)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What Should I call you?",
                              style: TextStyle(
                                color: progressData.darkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Copper',
                                fontSize: 30.0,
                              ),
                            ),
                            MyTextField('First Name', authData.setFN,
                                authData.fnController),
                            MyTextField('Last Name', authData.setLN,
                                authData.lnController),
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyButton('Go Back to Login', () {
                                  Navigator.pop(context);
                                }, 0.42),
                                MyButton('Go Ahead', () {
                                  // ✅ Fixed: Check both fields individually
                                  if (authData.fnController.text
                                          .trim()
                                          .isEmpty ||
                                      authData.lnController.text
                                          .trim()
                                          .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please enter both first and last name'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  print(authData.fn + ' first');
                                  print(authData.ln + ' last');
                                  authData.setRegistration(1); // Go to step 2
                                }, 0.30),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )

                // ✅ Step 2: Email (registrationValue == 2)
                else if (authData.registrationValue == 2)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What's your Email?",
                              style: TextStyle(
                                color: progressData.darkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Copper',
                                fontSize: 30.0,
                              ),
                            ),
                            MyTextField('Email', authData.setEmail,
                                authData.emailController),
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyButton('Go Back', () {
                                  authData
                                      .setRegistration(-1); // Go back to step 1
                                }, 0.25),
                                MyButton('Proceed', () {
                                  // ✅ Fixed: Check text property, not controller
                                  if (authData.emailController.text
                                      .trim()
                                      .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Please enter your email'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (!EmailValidator.validate(
                                      authData.emailController.text.trim())) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Please enter a valid email'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  authData.setRegistration(1); // Go to step 3
                                }, 0.30),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )

                // ✅ Step 3: Security Question (registrationValue == 3)
                else if (authData.registrationValue == 3)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Let's secure your account",
                              style: TextStyle(
                                color: progressData.darkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Copper',
                                fontSize: 30.0,
                              ),
                            ),
                            Text(
                              "We will ask this if you forget your password",
                              style: TextStyle(
                                color: progressData.darkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Copper',
                                fontSize: 15.0,
                              ),
                            ),
                            MyTextField(
                                'Security Question',
                                authData.setQuestion,
                                authData.questionController),
                            MyTextField('Your answer', authData.setAnswer,
                                authData.answerController),
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyButton('Go Back', () {
                                  authData
                                      .setRegistration(-1); // Go back to step 2
                                }, 0.25),
                                MyButton('Proceed', () {
                                  // ✅ Fixed: Validate security question and answer
                                  if (authData.questionController.text
                                          .trim()
                                          .isEmpty ||
                                      authData.answerController.text
                                          .trim()
                                          .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please enter both question and answer'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  authData.setRegistration(1); // Go to step 4
                                }, 0.30),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )

                // ✅ Step 4: Password (registrationValue == 4)
                else if (authData.registrationValue == 4)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Set Your Password!",
                              style: TextStyle(
                                color: progressData.darkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Copper',
                                fontSize: 30.0,
                              ),
                            ),
                            MyTextField('Password', authData.setPassword,
                                authData.passwordController),
                            MyTextField(
                                'Confirm Password',
                                authData.setConfirmPassword,
                                authData.confirmController),
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyButton('Go Back', () {
                                  authData
                                      .setRegistration(-1); // Go back to step 3
                                }, 0.25),
                                MyButton('Register', () {
                                  // ✅ Fixed: Better validation and removed registration reset
                                  if (authData.passwordController.text
                                      .trim()
                                      .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Please enter a password"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (authData.password !=
                                      authData.confirmPassword) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Passwords do not match"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  // ✅ Fixed: Removed the registration reset that was interfering
                                  authData.firebaseNewUserCreate(context);
                                }, 0.30),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )

                // ✅ Step 12: Forgot Password - Email Entry (registrationValue == 12)
                else if (authData.registrationValue == 12)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What's your Email?",
                              style: TextStyle(
                                color: progressData.darkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Copper',
                                fontSize: 30.0,
                              ),
                            ),
                            MyTextField('Email', authData.setEmail,
                                authData.emailController),
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyButton('Go Back To Login', () {
                                  authData.setRegistration(
                                      -(authData.registrationValue - 1));
                                  Navigator.pop(context);
                                }, 0.42),
                                MyButton('Proceed', () async {
                                  if (authData.emailController.text
                                      .trim()
                                      .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Please enter your email'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (!EmailValidator.validate(
                                      authData.emailController.text.trim())) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Please enter a valid email'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  await authData.fetchFirebaseData(context);
                                  if (authData.answer != '') {
                                    authData
                                        .setRegistration(1); // Go to step 13
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content:
                                            Text("Create your new Account"),
                                      ),
                                    );
                                  }
                                }, 0.30),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )

                // ✅ Step 13: Forgot Password - Security Answer (registrationValue == 13)
                else if (authData.registrationValue == 13)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authData.question,
                              style: TextStyle(
                                color: progressData.darkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: 'Copper',
                                fontSize: 30.0,
                              ),
                            ),
                            MyTextField('Answer', authData.setEnteredAnswer,
                                authData.enteredAnswerController),
                            SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyButton('Go Back', () {
                                  authData.setRegistration(
                                      -1); // Go back to step 12
                                }, 0.25),
                                MyButton('Proceed', () {
                                  if (authData.enteredAnswerController.text
                                      .trim()
                                      .isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Please enter your answer'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  print(authData.enteredAnswer.toLowerCase() +
                                      authData.answer.toLowerCase());
                                  if (authData.enteredAnswer
                                          .toString()
                                          .toLowerCase() ==
                                      authData.answer
                                          .toString()
                                          .toLowerCase()) {
                                    Provider.of<QuestionData>(context,
                                            listen: false)
                                        .getFirebaseDatabase(context);
                                    authData.resetPassword(
                                        context, authData.email);
                                    authData.setRegistration(
                                        -(authData.registrationValue - 1));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WelcomeScreen()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Incorrect answer'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }, 0.30),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                Image.asset('images/papergen_border_down.png'),
              ],
            ),
          ),
        );
      },
    );
  }
}
