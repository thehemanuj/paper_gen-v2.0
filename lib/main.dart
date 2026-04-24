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
import 'assets/NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('--- [App Setup] Starting main() ---');
  
  try {
    print('--- [App Setup] Initializing Hive ---');
    await Hive.initFlutter();
    // Await box opening here to ensure providers are ready immediately
    await Hive.openBox('authorisation-data');
    await Hive.openBox('progress-data');
    print('--- [App Setup] Hive ready ---');

    print('--- [App Setup] Initializing Firebase ---');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('--- [App Setup] Firebase ready ---');

    print('--- [App Setup] Initializing Notification Service ---');
    await NotificationService().init();
    print('--- [App Setup] Notification Service ready ---');

    print('--- [App Setup] Running MyApp ---');
    runApp(const MyApp());
  } catch (e) {
    print('--- [App Setup] CRITICAL ERROR during initialization: $e');
    // We still want to run the app so it can show an error screen instead of a blank splash
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Failed to initialize app: $e', style: const TextStyle(color: Colors.red))),
      ),
    ));
  }
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
        debugShowCheckedModeBanner: false,
        title: 'Paper Gen',
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            print('--- [Auth Stream] Connection State: ${snapshot.connectionState}');
            
            if (snapshot.hasError) {
              print('--- [Auth Stream] ERROR: ${snapshot.error}');
              return Scaffold(
                body: Center(child: Text('Authentication error: ${snapshot.error}')),
              );
            }

            // 1. If Firebase is still connecting, show loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('--- [Auth Stream] Showing loading screen ---');
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
              print('--- [Auth Stream] User is logged in: ${snapshot.data?.email}');
              // Ensure our provider knows we are logged in for internal logic
              if (!authData.rememberedData) {
                // We use a small hack to update the provider without triggering a rebuild mid-stream
                Future.microtask(() => authData.fetchBoxData());
              }
              return WelcomeScreen();
            }

            print('--- [Auth Stream] User is NOT logged in, showing Login Screen ---');
            // 4. Otherwise, show login screen
            return AuthorisationScreen();
          },
        ),
      ),
    );
  }
}

