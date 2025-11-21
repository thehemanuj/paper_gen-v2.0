import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paper_gen/ProviderData/AuthorisationData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:paper_gen/assets/MyPreferenceBox.dart';
import 'package:paper_gen/assets/MySelector.dart';
import 'package:provider/provider.dart';

import '../ProviderData/ProgressData.dart';
import '../assets/MyContainer.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<ProgressData>(context).darkMode
          ? Color(0xff0A0E27)
          : Color(0xffFDFBF7),
      body: Consumer3<AuthorisationData, ProgressData, QuestionData>(builder:
          (BuildContext context, authData, proData, qData, Widget? child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('images/papergen_border_up.png'),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.arrowLeft,
                            size: 35.0,
                            color: Color(0xff26a69a),
                          ),
                          SizedBox(width: 10.0), // Added spacing
                          Text(
                            'Continue with PaperGen',
                            style: TextStyle(
                                color: Color(0xff26a69a),
                                fontFamily: 'Copper',
                                fontSize: 22.0),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    MyContainer(),
                    SizedBox(height: 20.0),
                    Text(
                      "Preferences",
                      style: TextStyle(
                          color: Color(0xff26a69a),
                          fontFamily: 'Copper',
                          fontSize: 25.0),
                    ),
                    SizedBox(height: 10.0),
                    MyPreferenceBox(Column(
                      children: [
                        MyCard(
                            'Notifications',
                            'We are working on this rn',
                            FontAwesomeIcons.bell,
                            () {},
                            Switch(
                              value: Provider.of<ProgressData>(context)
                                  .notificationsEnabled,
                              activeThumbColor: Color(0xff26a69a),
                              inactiveThumbColor: proData.darkMode
                                  ? const Color(0xff0A0E27)
                                  : const Color(0xffFDFBF7),
                              onChanged: (bool value) {
                                Provider.of<ProgressData>(context,
                                        listen: false)
                                    .setNotificationsEnabled(value);
                              },
                            )),
                        Divider(),
                        MyCard(
                            'Dark Mode',
                            'Set as you prefer',
                            proData.darkMode
                                ? FontAwesomeIcons.cloudMoon
                                : FontAwesomeIcons.sun,
                            () {},
                            Switch(
                              value: proData.darkMode,
                              activeThumbColor: Color(0xff26a69a),
                              inactiveThumbColor: proData.darkMode
                                  ? const Color(0xff0A0E27)
                                  : const Color(0xffFDFBF7),
                              onChanged: (_) {
                                Provider.of<ProgressData>(context,
                                        listen: false)
                                    .setDarkMode();
                              },
                            )),
                        Divider(),
                        MyCard(
                          "Language",
                          'English',
                          FontAwesomeIcons.language,
                          () {},
                          Icon(
                            FontAwesomeIcons.arrowRight,
                            color: Color(0xff26a69a),
                          ),
                        )
                      ],
                    )),
                    SizedBox(height: 20.0),
                    Text(
                      "Settings",
                      style: TextStyle(
                          color: Color(0xff26a69a),
                          fontFamily: 'Copper',
                          fontSize: 25.0),
                    ),
                    SizedBox(height: 10.0),
                    MyPreferenceBox(Column(
                      children: [
                        MyCard(
                          'Default Difficulty',
                          'Choose the difficulty',
                          FontAwesomeIcons.rainbow,
                          () {
                            showDifficultyDialog(context); // Open dialog on tap
                          },
                          const DifficultyDialogButton(), // Shows current selection
                        ),
                      ],
                    )),
                    SizedBox(height: 20.0),
                    MyLogoutButton('LogOut', () => authData.logOut(context), 1),
                    SizedBox(
                      height: 100.0,
                    )
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
