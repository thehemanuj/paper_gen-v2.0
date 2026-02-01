import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paper_gen/ProviderData/AuthorisationData.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:paper_gen/assets/MyBox.dart';
import 'package:paper_gen/assets/MyLongBox.dart';
import 'package:paper_gen/screens/GenerateAPaperScreen.dart';
import 'package:paper_gen/screens/SettingScreen.dart';
import 'package:provider/provider.dart';

import '../ProviderData/QuestionData.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Wait for the first frame to be built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final authData = Provider.of<AuthorisationData>(context, listen: false);
      final qData = Provider.of<QuestionData>(context, listen: false);

      // Only load if user is logged in and data hasn't been loaded yet
      if (authData.email.isNotEmpty &&
          authData.rememberedData &&
          !qData.isDataLoaded) {
        await qData.getFirebaseDatabase(context);
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthorisationData, ProgressData, QuestionData>(
      builder: (BuildContext context, authData, proData, qData, Widget? child) {
        // Show loading indicator while initializing
        if (!_isInitialized ||
            (authData.email.isNotEmpty &&
                authData.rememberedData &&
                !qData.isDataLoaded)) {
          return Scaffold(
            backgroundColor:
                proData.darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xff26a69a),
              ),
            ),
          );
        }

        return ModalProgressHUD(
          inAsyncCall: proData.loading == 1,
          progressIndicator: CircularProgressIndicator(
            color: Color(0xff26a69a),
          ),
          child: Scaffold(
            backgroundColor:
                proData.darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
              child: FloatingActionButton(
                backgroundColor: Color(0xff26A69A),
                onPressed: () {
                  Provider.of<ProgressData>(context, listen: false)
                      .setDarkMode();
                },
                child: Icon(
                  proData.darkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  proData.darkMode
                      ? Image.asset('images/papergen_bg2_dark.png')
                      : Image.asset('images/papergen_bg2_light.png'),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${qData.getTime()[0]} ${authData.fn.isNotEmpty ? authData.fn[0].toUpperCase() + authData.fn.substring(1).toLowerCase() : "User"} ${qData.getTime()[1]}',
                          style: TextStyle(
                            fontFamily: 'Copper',
                            color: proData.darkMode
                                ? Color(0xffFDFBF7)
                                : Color(0xff0A0E27),
                            fontSize: 30.0,
                          ),
                        ),
                        Text(
                          qData.getRandomTagline(),
                          style: TextStyle(
                            fontFamily: 'Copper',
                            color: proData.darkMode
                                ? Color(0xffFDFBF7)
                                : Color(0xff0A0E27),
                            fontSize: 15.0,
                          ),
                        ),
                        SizedBox(height: 30),
                        MyButton('Generate A Paper', () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GeneratePaperScreen()));
                        }, 1),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            MyBox(FontAwesomeIcons.clock, 'Past Papers',
                                '${qData.pastPapers.length} Papers', () {}),
                            SizedBox(
                              width: 10.0,
                            ),
                            MyBox(FontAwesomeIcons.bookOpen, 'Practice Mode',
                                'Quick And Fast', () {}),
                          ],
                        ),
                        SizedBox(height: 30.0),
                        Text(
                          'Your Progress',
                          style: TextStyle(
                            fontFamily: 'Copper',
                            color: proData.darkMode
                                ? Color(0xffFDFBF7)
                                : Color(0xff0A0E27),
                            fontSize: 20.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        MyLongBox(
                            qData.pastPapers.length,
                            qData.correct,
                            qData.totalAttempted,
                            qData.subjects.length,
                            1,
                            () {}),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text(
                          'Quick Access',
                          style: TextStyle(
                            fontFamily: 'Copper',
                            color: proData.darkMode
                                ? Color(0xffFDFBF7)
                                : Color(0xff0A0E27),
                            fontSize: 20.0,
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                MyBox(FontAwesomeIcons.calculator,
                                    "Mathematics", '', () {
                                  qData.addSubject('Mathematics');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GeneratePaperScreen()));
                                },
                                    color: proData.darkMode
                                        ? Colors.white30
                                        : Colors.grey[800]),
                                SizedBox(
                                  width: 10.0,
                                ),
                                MyBox(FontAwesomeIcons.earthAsia,
                                    "General Knowledge", '', () {
                                  qData.addSubject('General Knowledge');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GeneratePaperScreen()));
                                }, color: Colors.blue[900]),
                                SizedBox(
                                  width: 10.0,
                                ),
                                MyBox(
                                  FontAwesomeIcons.brain,
                                  'Aptitude&Reasoning',
                                  '',
                                  () {
                                    qData.addSubject('Aptitude&Reasoning');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GeneratePaperScreen()));
                                  },
                                  color: Color(0xfffa87a2),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                MyBox(
                                  FontAwesomeIcons.a,
                                  "English",
                                  '',
                                  () {
                                    qData.addSubject('English');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GeneratePaperScreen()));
                                  },
                                  color: Colors.amber,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                MyBox(FontAwesomeIcons.computer,
                                    "Computer Science", '', () {
                                  qData.addSubject('Computer Science');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GeneratePaperScreen()));
                                }, color: Colors.grey),
                                SizedBox(
                                  width: 10.0,
                                ),
                                MyBox(
                                  FontAwesomeIcons.apple,
                                  'DSA',
                                  '',
                                  () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GeneratePaperScreen()));
                                  },
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            SizedBox(height: 30.0),
                            MyButton('Settings & Preferences ⚙️', () {
                              qData.addSubject('DSA');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingScreen()));
                            }, 1)
                          ],
                        )
                      ],
                    ),
                  ),
                  Image.asset('images/papergen_border_down.png')
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
