import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paper_gen/ProviderData/AuthorisationData.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:paper_gen/assets/MyBox.dart';
import 'package:paper_gen/assets/MyLongBox.dart';
import 'package:paper_gen/screens/assessment/GenerateAPaperScreen.dart';
import 'package:paper_gen/screens/dashboard/learn_section.dart';
import 'package:paper_gen/screens/past_paper/PastPapersScreen.dart';
import 'package:paper_gen/screens/authentication/ScoreScreen.dart';
import 'package:paper_gen/screens/dashboard/SettingScreen.dart';
import 'package:provider/provider.dart';

import '../../ProviderData/QuestionData.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final authData = Provider.of<AuthorisationData>(context, listen: false);
      final qData = Provider.of<QuestionData>(context, listen: false);

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
                            fontSize: 25.0,
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
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.monetization_on,
                                color: Colors.amber, size: 20),
                            SizedBox(width: 5),
                            Text(
                              '${qData.coins} Coins',
                              style: TextStyle(
                                  color: proData.darkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        MyButton('Generate A Paper', () {
                          Provider.of<QuestionData>(context, listen: false)
                              .setTimerEnabled(false);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GeneratePaperScreen()));
                        }, 1),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            MyBox(FontAwesomeIcons.clock, 'Past Papers',
                                '${qData.pastPapers.length} Papers', () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PastPapersScreen()));
                            }),
                            SizedBox(
                              width: 10.0,
                            ),
                            MyBox(FontAwesomeIcons.bookOpen, 'Practice Mode',
                                'Quick And Fast', () {
                              Provider.of<QuestionData>(context, listen: false)
                                  .setTimerEnabled(true);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GeneratePaperScreen()));
                            }),
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
                            qData.totalQuestionsCorrect,
                            qData.totalQuestionsAttempted,
                            qData.subjectsAttempted.length,
                            1, () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScoreScreen(1)));
                        }),
                        SizedBox(
                          height: 30.0,
                        ),
                        LearnSection(),
                        SizedBox(height: 30.0),
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
                                  Provider.of<QuestionData>(context,
                                          listen: false)
                                      .setTimerEnabled(false);
                                  qData.selectSubject('Mathematics');
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
                                  Provider.of<QuestionData>(context,
                                          listen: false)
                                      .setTimerEnabled(false);
                                  qData.selectSubject('General Knowledge');
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
                                  'Aptitude & Reasoning',
                                  '',
                                  () {
                                    Provider.of<QuestionData>(context,
                                            listen: false)
                                        .setTimerEnabled(false);
                                    qData.selectSubject('Aptitude&Reasoning');
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
                                    Provider.of<QuestionData>(context,
                                            listen: false)
                                        .setTimerEnabled(false);
                                    qData.selectSubject('English');
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
                                  Provider.of<QuestionData>(context,
                                          listen: false)
                                      .setTimerEnabled(false);
                                  qData.selectSubject('Computer Science');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GeneratePaperScreen()));
                                }, color: Colors.blueGrey),
                                SizedBox(
                                  width: 10.0,
                                ),
                                MyBox(
                                  FontAwesomeIcons.apple,
                                  'DSA',
                                  '',
                                  () {
                                    Provider.of<QuestionData>(context,
                                            listen: false)
                                        .setTimerEnabled(false);
                                    qData.selectSubject('DSA');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GeneratePaperScreen()));
                                  },
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            SizedBox(height: 30.0),
                            MyButton('Settings & Preferences ⚙️', () {
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
