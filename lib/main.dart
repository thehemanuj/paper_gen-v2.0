import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/AuthorisationData.dart';
import 'package:paper_gen/screens/assessment/FinalQuestionScreen.dart';
import 'package:paper_gen/screens/authentication/LoginScreen.dart';
import 'package:paper_gen/screens/authentication/ScoreScreen.dart';
import 'package:paper_gen/screens/dashboard/WelcomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ProviderData/ProgressData.dart';
import 'firebase_options.dart';
import 'ProviderData/QuestionData.dart';

void main() async {
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthorisationData()),
        ChangeNotifierProvider(create: (_) => QuestionData()),
        ChangeNotifierProvider(create: (_) => ProgressData())
      ],
      child: MaterialApp(
        home: Consumer<AuthorisationData>(
          builder: (context, authData, child) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: authData.rememberedData
                  ? WelcomeScreen()
                  : AuthorisationScreen(),
            );
          },
        ),
      ),
    );
  }
}
