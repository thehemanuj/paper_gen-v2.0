import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // 1. If Firebase is still connecting, show loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xff0A0E27),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xff26A69A)),
                ),
              );
            }

            // 2. Fetch our custom auth data provider
            final authData = Provider.of<AuthorisationData>(context, listen: false);

            // 3. If we have a user from Firebase, they are logged in
            if (snapshot.hasData && snapshot.data != null) {
              // Ensure our provider knows we are logged in for internal logic
              if (!authData.rememberedData) {
                // We use a small hack to update the provider without triggering a rebuild mid-stream
                Future.microtask(() => authData.fetchBoxData());
              }
              return WelcomeScreen();
            }

            // 4. Otherwise, show login screen
            return AuthorisationScreen();
          },
        ),
      ),
    );
  }
}
