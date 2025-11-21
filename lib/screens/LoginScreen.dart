import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:paper_gen/assets/TextField.dart';
import 'package:paper_gen/screens/RegistrationScreen.dart';
import 'package:provider/provider.dart';

import '../ProviderData/AuthorisationData.dart';
import '../ProviderData/ProgressData.dart';

class AuthorisationScreen extends StatelessWidget {
  const AuthorisationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ProgressData>(context).darkMode;
    return Consumer<AuthorisationData>(
      builder:
          (BuildContext context, AuthorisationData authData, Widget? child) {
        return Scaffold(
          backgroundColor:
              Provider.of<ProgressData>(context, listen: true).darkMode
                  ? Color(0xff0A0E27)
                  : Color(0xffFDFBF7),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: FloatingActionButton(
              backgroundColor: Color(0xff26A69A),
              onPressed: () {
                Provider.of<ProgressData>(context, listen: false).setDarkMode();
              },
              child: Icon(
                darkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
          ),
          body: ModalProgressHUD(
            progressIndicator: CircularProgressIndicator(
              color: Color(0xff26A69A),
            ),
            inAsyncCall:
                Provider.of<ProgressData>(context, listen: true).loading == 1,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage(darkMode
                        ? 'images/papergen_dark.png'
                        : 'images/papergen_light.png'),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start, // Add this
                      children: [
                        Text(
                          'Welcome, Legend!',
                          style: TextStyle(
                              color: darkMode ? Colors.white : Colors.black,
                              fontFamily: 'Copper',
                              fontSize: 30.0),
                        ),
                        MyTextField('Username', authData.setUsername,
                            authData.emailController),
                        MyTextField('Password', authData.setPassword,
                            authData.passwordController),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Transform.scale(
                                  scale:
                                      1.2, // Try values like 1.2, 1.5, 2.0 for desired size
                                  child: Checkbox(
                                    activeColor: darkMode
                                        ? Color(0xff36d0c2)
                                        : Color(0xff26a69a),
                                    checkColor: darkMode
                                        ? Colors.white
                                        : Color(0xff0A0E27),
                                    side: BorderSide(
                                      color: Color(0xff26a69a),
                                      width: 2.0,
                                    ),
                                    value: authData.remember,
                                    onChanged: (text) {
                                      authData.setRemember();
                                    },
                                  ),
                                ),
                                Text(
                                  "Remember me",
                                  style: TextStyle(
                                      color: darkMode
                                          ? Color(0xff36d0c2)
                                          : Color(0xff26a69a),
                                      fontFamily: 'Copper',
                                      fontSize: 15.0),
                                )
                              ],
                            ),
                            TextButton(
                              style: ButtonStyle(
                                  overlayColor: WidgetStatePropertyAll(
                                      Colors.transparent)),
                              onPressed: () {
                                authData.setRegistration(11);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RegistrationScreen()));
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: darkMode
                                        ? Color(0xff36d0c2)
                                        : Color(0xff26a69a),
                                    fontFamily: 'Copper',
                                    fontSize: 15.0),
                              ),
                            ),
                          ],
                        ),
                        MyButton('Let\'s Rock', () {
                          authData.checkForEmailAndPassword(context);
                        }, 1),
                        SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: TextButton(
                            style: ButtonStyle(
                                overlayColor:
                                    WidgetStatePropertyAll(Colors.transparent)),
                            onPressed: () {
                              authData.emptyBox();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegistrationScreen()),
                              );
                            },
                            child: Text(
                              'New here??? Let\'s Register you!',
                              style: TextStyle(
                                  color: darkMode
                                      ? Color(0xff36d0c2)
                                      : Color(0xff26a69a),
                                  fontFamily: 'Copper',
                                  fontSize: 15.0),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
