import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:paper_gen/screens/assessment/DesiredExam.dart';
import 'package:paper_gen/screens/dashboard/WelcomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import '../screens/authentication/LoginScreen.dart';
import 'QuestionData.dart';

class AuthorisationData extends ChangeNotifier {
  AuthorisationData() {
    _initialiseHive();
  }

  late Box box;
  bool _isInitialised = false;

  final fnController = TextEditingController();
  final lnController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final answerController = TextEditingController();
  final questionController = TextEditingController();
  final enteredAnswerController = TextEditingController();

  String _username = '';
  String _password = '';
  String _email = '';
  String _fn = '';
  String _ln = '';
  String _confirmPassword = '';
  String _question = '';
  String _answer = '';
  String _enteredAnswer = '';
  bool _remember = false;
  bool _rememberedData = false;
  int _registrationValue = 1;
  late UserCredential user;

  String get username => _username;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get fn => _fn;
  String get ln => _ln;
  String get question => _question;
  String get answer => _answer;
  String get enteredAnswer => _enteredAnswer;
  bool get remember => _remember;
  bool get rememberedData => _rememberedData;
  int get registrationValue => _registrationValue;

  void setUsername(String text) {
    _username = text.trim();
    notifyListeners();
  }

  void setEmail(String text) {
    _email = text.trim();
    notifyListeners();
  }

  void setPassword(String text) {
    _password = text.trim();
    notifyListeners();
  }

  void setConfirmPassword(String text) {
    _confirmPassword = text.trim();
    notifyListeners();
  }

  void setFN(String text) {
    _fn = text.trim();
    notifyListeners();
  }

  void setLN(String text) {
    _ln = text.trim();
    notifyListeners();
  }

  void setQuestion(String text) {
    _question = text.trim();
    notifyListeners();
  }

  void setAnswer(String text) {
    _answer = text.trim();
    notifyListeners();
  }

  void setEnteredAnswer(String text) {
    _enteredAnswer = text.trim();
    notifyListeners();
  }

  void setRemember() {
    _remember = !_remember;
    if (!_remember && _isInitialised) {
      box.clear();
    }
    notifyListeners();
  }

  void setRegistration(int value) {
    _registrationValue += value;
    notifyListeners();
  }

  Future<void> _initialiseHive() async {
    try {
      box = await Hive.openBox('authorisation-data');
      _isInitialised = true;
      fetchBoxData();
    } catch (e) {
      print('Error initializing Hive: $e');
    }
  }

  void fetchBoxData() {
    if (!_isInitialised || box.isEmpty) return;

    try {
      if (box.containsKey('remember')) {
        _rememberedData = box.get('remember', defaultValue: false);
        if (!_rememberedData) {
          box.clear();
          notifyListeners();
          return;
        }
      }

      _username = box.get('username', defaultValue: '');
      _email = box.get('email', defaultValue: '');
      _fn = box.get('fn', defaultValue: '');
      _ln = box.get('ln', defaultValue: '');
      notifyListeners();
    } catch (e) {
      print('Error fetching box data: $e');
    }
  }

  Future<void> emptyBox() async {
    if (!_isInitialised) return;

    try {
      await box.clear();

      _username = '';
      _password = '';
      _email = '';
      _confirmPassword = '';
      _enteredAnswer = '';

      clearAllControllers();

      notifyListeners();
    } catch (e) {
      print('Error clearing box: $e');
    }
  }

  void clearSensitiveData() {
    _username = '';
    _password = '';
    _confirmPassword = '';
    _enteredAnswer = '';

    emailController.clear();
    passwordController.clear();
    confirmController.clear();
    enteredAnswerController.clear();

    notifyListeners();
  }

  void clearAllControllers() {
    fnController.clear();
    lnController.clear();
    emailController.clear();
    passwordController.clear();
    confirmController.clear();
    questionController.clear();
    answerController.clear();
    enteredAnswerController.clear();
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed. Please try again or Check your internet connection.';
    }
  }

  void checkForEmailAndPassword(BuildContext context) {
    if (_username.isEmpty || _password.isEmpty) {
      _showSnackBar(context, 'Please enter username and password', Colors.red);
      return;
    }

    if (!EmailValidator.validate(_username)) {
      _showSnackBar(context, 'Please enter a valid email address', Colors.red);
      return;
    }

    _email = _username;
    firebaseLogIn(context);
  }

  Future<void> firebaseLogIn(BuildContext context) async {
    if (!context.mounted) return;

    try {
      Provider.of<ProgressData>(context, listen: false).setLoading(1);

      user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      await fetchFirebaseData(context);

      if (context.mounted) {
        await Provider.of<QuestionData>(context, listen: false)
            .getFirebaseDatabase(context);
        await Provider.of<QuestionData>(context, listen: false)
            .fetchSelectedSubject(context);
      }

      if (_remember && _isInitialised) {
        await box.put('remember', true);
        await box.put('username', _username);
        await box.put('email', _email);
        await box.put('fn', _fn);
        await box.put('ln', _ln);
      }

      if (!context.mounted) return;
      Provider.of<ProgressData>(context, listen: false).setLoading(0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );

      _showSnackBar(context, 'Login successful!', const Color(0xff26a69a));
      clearAllControllers();
      clearSensitiveData();
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Provider.of<ProgressData>(context, listen: false).setLoading(0);

      final errorMessage = _getFirebaseAuthErrorMessage(e.code);
      _showSnackBar(context, errorMessage, Colors.red);

      clearSensitiveData();
    } catch (e) {
      if (!context.mounted) return;
      Provider.of<ProgressData>(context, listen: false).setLoading(0);

      print('Login error: $e');
      _showSnackBar(
          context, 'An error occurred. Please try again.', Colors.red);

      clearSensitiveData();
    }
  }

  Future<void> firebaseNewUserCreate(BuildContext context) async {
    if (!context.mounted) return;

    try {
      Provider.of<ProgressData>(context, listen: false).setLoading(1);

      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      if (user.user?.email == _email) {
        print("Created user successfully");

        await firebasePutData();

        if (context.mounted) {
          await Provider.of<QuestionData>(context, listen: false)
              .getFirebaseDatabase(context);
        }

        if (_remember && _isInitialised) {
          await box.put('remember', true);
          await box.put('username', _username);
          await box.put('email', _email.toLowerCase());
          await box.put('fn', _fn);
          await box.put('ln', _ln);
        }

        if (!context.mounted) return;
        Provider.of<ProgressData>(context, listen: false).setLoading(0);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AskPaperScreen()),
        );

        _showSnackBar(
          context,
          'Account created successfully!',
          const Color(0xff26a69a),
        );

        clearAllControllers();
        clearSensitiveData();
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Provider.of<ProgressData>(context, listen: false).setLoading(0);

      final errorMessage = _getFirebaseAuthErrorMessage(e.code);
      print("Registration error: $e");

      _showSnackBar(context, errorMessage, Colors.red);

      clearSensitiveData();
      await emptyBox();
      setRegistration(-(_registrationValue - 1));
    } catch (e) {
      if (!context.mounted) return;
      Provider.of<ProgressData>(context, listen: false).setLoading(0);

      print("Unexpected error during registration: $e");
      _showSnackBar(
        context,
        'An unexpected error occurred. Please try again.',
        Colors.red,
      );

      clearSensitiveData();
      await emptyBox();
      setRegistration(-(_registrationValue - 1));
    }
  }

  Future<void> firebasePutData() async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('user_data')
          .doc(_email.toLowerCase());

      final docSnapshot = await userRef.get();

      if (!docSnapshot.exists) {
        await userRef.set({
          'fn': _fn,
          'ln': _ln,
          'question': _question,
          'answer': _answer,
        });
      }
    } catch (e) {
      print('Error saving user data to Firestore: $e');
      rethrow;
    }
  }

  Future<void> fetchFirebaseData(BuildContext context) async {
    if (!context.mounted) return;

    try {
      Provider.of<ProgressData>(context, listen: false).setLoading(1);

      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('user_data')
          .doc(_email.toLowerCase())
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();

        if (data != null) {
          _fn = data['fn'] as String? ?? '';
          _ln = data['ln'] as String? ?? '';
          _question = data['question'] as String? ?? 'No question';
          _answer = data['answer'] as String? ?? '';
          notifyListeners();
        }
      } else {
        print("No user found with email $_email");
      }
    } catch (e) {
      print("Error fetching Firebase data: $e");
    } finally {
      if (context.mounted) {
        Provider.of<ProgressData>(context, listen: false).setLoading(0);
      }
    }
  }

  Future<void> resetPassword(BuildContext context, email) async {
    if (!context.mounted) return;

    await fetchFirebaseData(context);

    if (_question != '' && _question != 'No question') {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _showSnackBar(
          context,
          "Password reset email has been sent successfully",
          const Color(0xff26a69a),
        );
      } catch (e) {
        print("Error sending password reset email: $e");
        _showSnackBar(
          context,
          "Failed to send password reset email",
          Colors.red,
        );
      }
    } else {
      _showSnackBar(
        context,
        "No account found. Please create a new account.",
        Colors.red,
      );
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (_isInitialised) {
        await box.put('remember', false);
        await box.clear();
      }

      if (context.mounted) {
        Provider.of<QuestionData>(context, listen: false).resetData();
      }

      _username = '';
      _email = '';
      _password = '';
      _confirmPassword = '';
      _question = '';
      _enteredAnswer = '';
      _remember = false;
      _rememberedData = false;
      _registrationValue = 1;

      clearAllControllers();
      notifyListeners();

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthorisationScreen()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  void dispose() {
    fnController.dispose();
    lnController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    questionController.dispose();
    answerController.dispose();
    enteredAnswerController.dispose();
    super.dispose();
  }
}
