import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiavatar/multiavatar.dart';
import 'package:provider/provider.dart';

import 'package:paper_gen/ProviderData/AuthorisationData.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/assets/HelperClasses.dart';
import 'package:http/http.dart' as http;

import '../screens/FinalQuestionScreen.dart';

// ============================================================================
// MODEL CLASSES
// ============================================================================

/// Configuration for a subject in the paper generation
class SubjectConfig {
  String id;
  String name;
  String difficulty;
  int questionCount;

  SubjectConfig({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.questionCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'questionCount': questionCount,
    };
  }

  factory SubjectConfig.fromMap(Map<String, dynamic> map) {
    return SubjectConfig(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      questionCount: map['questionCount'] ?? 10,
    );
  }
}

// ============================================================================
// MAIN PROVIDER CLASS
// ============================================================================

class QuestionData extends ChangeNotifier {
  QuestionData();

  // ============================================================================
  // CONSTANTS
  // ============================================================================

  final List<String> _difficultyList = [
    'Easy',
    'Medium',
    'Hard',
    'Expert',
    'Professional',
    'God',
  ];

  final List<String> _availableSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
    'Geography',
    'Computer Science',
    'Economics',
    'Accounts',
    'Business Studies',
    'Political Science',
    'Psychology',
    'Sociology',
    'Statistics',
    'DSA',
    'Hindi',
    'General Knowledge',
    'Aptitude&Reasoning',
  ];

  final List<String> coolTagLines = [
    "How's your vibe today?",
    "Ready to explore something new?",
    "What's on your learning list?",
    "What goal are you chasing right now?",
    "Got a fresh idea in mind?",
    "What's keeping you inspired today?",
    "What's the soundtrack of your mood?",
    "Where's your curiosity taking you?",
    "Want to solve a puzzle together?",
    "What's sparking your energy today?",
    "Building something cool lately?",
    "What challenge are you leveling up on?",
    "What colors your day right now?",
    "What's the highlight of your week?",
    "Where do you want to head next?",
    "What's bringing you luck today?",
    "What story are you writing right now?",
    "What's your creative spark today?",
    "What dream are you chasing?",
    "What's your next big win?",
    "What skill are you sharpening today?",
    "What's the best idea you had this week?",
    "What challenge are you excited to tackle?",
    "What's fueling your motivation right now?",
    "What's the most fun thing you did today?",
    "What's your next experiment?",
    "What's the bold step you're planning?",
    "What's the coolest thing you learned recently?",
    "What's your focus for the day?",
    "What's the milestone you're aiming for?",
  ];

  final int _maxQuestionsAllowed = 100;

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  // User data
  var _avatar = "";
  var _config = Map<int, int>();
  var _totalQuestionsGenerated = 0;
  var _totalQuestionsViewed = 0;
  var _totalQuestionsAttempted = 0;
  var _totalQuestionsCorrect = 0;
  var _totalQuestionsIncorrect = 0;
  List<String> _subjectsAttempted = [];
  var _streak = 0;
  var _badges = [];
  var _role = "student";
  var _coins = 0;
  var _pastPapers = [];
  var _correctLocal = 0;
  var _attempted = Map<int, int>();
  bool _isDataLoaded = false;

  // Difficulty settings
  String _selectedDefaultDifficulty = 'Easy';
  var _selectedDifficulty = '';

  // Paper generation — single subject only
  SubjectConfig? _selectedSubject;
  GeneratedPaper? _currentGeneratedPaper;
  final List<GeneratedPaper> _generatedPapers = [];
  var _viewed = <int>{0};

  // ============================================================================
  // GETTERS
  // ============================================================================

  // Example getters for your class fields

  String get avatar => _avatar;
  Map<int, int> get config => _config;
  int get totalQuestionsGenerated => _totalQuestionsGenerated;
  int get totalQuestionsViewed => _totalQuestionsViewed;
  int get totalQuestionsAttempted => _totalQuestionsAttempted;
  int get totalQuestionsCorrect => _totalQuestionsCorrect;
  int get totalQuestionsIncorrect => _totalQuestionsIncorrect;
  List get subjectsAttempted => _subjectsAttempted;
  int get streak => _streak;
  List get badges => _badges;
  String get role => _role;
  int get coins => _coins;
  List get pastPapers => _pastPapers;
  int get correctLocal => _correctLocal;
  Map<int, int> get attempted => _attempted;
  bool get isDataLoaded => _isDataLoaded;
// Difficulty settings
  String get selectedDefaultDifficulty => _selectedDefaultDifficulty;
  String get selectedDifficulty => _selectedDifficulty;

// Paper generation
  SubjectConfig? get selectedSubject => _selectedSubject;
  GeneratedPaper? get currentGeneratedPaper => _currentGeneratedPaper;
  List<GeneratedPaper> get generatedPapers => _generatedPapers;
  Set<int> get viewed => _viewed;
  List<String> get availableSubjects => _availableSubjects;

  int get maxQuestionsAllowed => _maxQuestionsAllowed;
  bool get isSubjectSelected => _selectedSubject != null;
  int get totalQuestions => _selectedSubject?.questionCount ?? 0;
  get difficultyList => _difficultyList;
  // ============================================================================
  // USER DATA METHODS
  // ============================================================================

  setTotalQuestionsGenerated(int value) {
    _totalQuestionsGenerated += value;
    notifyListeners();
  }

  setTotalQuestionsAttempted() {
    _totalQuestionsAttempted += 1;
    notifyListeners();
  }

  setTotalQuestionsIncorrect() {
    _totalQuestionsIncorrect += 1;
    notifyListeners();
  }

  getImage() {
    String image = multiavatar(_avatar);
    return image;
  }

  setCorrect() {
    _correctLocal += 1;
    _totalQuestionsCorrect += 1;
    notifyListeners();
  }

  setAttempted(int questionNumber, int optionNumber) {
    if (!_attempted.containsKey(questionNumber)) {
      setTotalQuestionsAttempted();
    }
    _attempted[questionNumber] = optionNumber;

    notifyListeners();
  }

  setTotalQuestionsViewed() {
    _totalQuestionsViewed += 1;
    notifyListeners();
  }

  setViewed(value) {
    if (!_viewed.contains(value)) {
      setTotalQuestionsViewed();
    }
    _viewed.add(value);
    notifyListeners();
  }

  setCoins(int coins) {
    _coins += coins;
    notifyListeners();
  }

  setBadges(String badge) {
    _badges.add(badge);
    notifyListeners();
  }

  void setSubjectsAttempted(String subject) {
    if (!_subjectsAttempted.contains(subject)) {
      _subjectsAttempted.add(subject);
      notifyListeners();
    }
  }

  void setStreak() {
    _streak += 1;
    notifyListeners();
  }

  // ============================================================================
  // DIFFICULTY METHODS
  // ============================================================================

  setSelectedDefaultDifficulty(i) {
    _selectedDefaultDifficulty = _difficultyList[i];
    notifyListeners();
  }

  setSelectedDifficulty(i) {
    _selectedDifficulty = _difficultyList[i];
    notifyListeners();
  }

  // ============================================================================
  // SUBJECT MANAGEMENT METHODS
  // ============================================================================

  /// Selects a subject. Replaces any previously selected subject.
  void selectSubject(String subjectName) {
    _selectedSubject = SubjectConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: subjectName,
      difficulty: _selectedDefaultDifficulty,
      questionCount: 10,
    );
    notifyListeners();
  }

  /// Clears the currently selected subject.
  void clearSelectedSubject() {
    _selectedSubject = null;
    notifyListeners();
  }

  /// Updates the difficulty of the selected subject.
  void updateDifficulty(String difficulty) {
    if (_selectedSubject == null) return;
    _selectedSubject!.difficulty = difficulty;
    notifyListeners();
  }

  /// Updates the question count of the selected subject, clamped between 1 and maxQuestionsAllowed.
  void updateQuestionCount(int count) {
    if (_selectedSubject == null) return;
    _selectedSubject!.questionCount = count.clamp(1, _maxQuestionsAllowed);
    notifyListeners();
  }

  /// Toggles whether the selected subject should include multiple-choice options.

  /// Returns available subjects filtered by a search query.
  /// Excludes the currently selected subject so it can't be picked again.
  List<String> getFilteredSubjects(String query) {
    final lowerQuery = query.toLowerCase();
    return _availableSubjects
        .where((subject) =>
            subject.toLowerCase().contains(lowerQuery) &&
            subject != _selectedSubject?.name)
        .toList();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  getTime() {
    DateTime dateTime = DateTime.now();
    if (dateTime.hour <= 11 && dateTime.hour >= 5) {
      return ["Good Morning", "☕"];
    } else if (dateTime.hour > 11 && dateTime.hour < 16) {
      return ["Good Afternoon", "🌞"];
    } else if (dateTime.hour >= 16 && dateTime.hour < 22) {
      return ["Good Evening", "🌕"];
    } else {
      return ["Heyy Night Owl", "🦉"];
    }
  }

  getRandomTagline() {
    var r = Random();
    int a = r.nextInt(coolTagLines.length);
    return coolTagLines[a];
  }

  String generateUniqueId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    // Week of the year
    final dayOfYear = int.parse(DateFormat("D").format(now));
    final weekOfYear = ((dayOfYear - now.weekday + 10) / 7).floor();

    // Time (HHmmss)
    final time = DateFormat("HHmmss").format(now);

    return "${year}_${month}_${day}_W${weekOfYear}_$time";
  }

  // ============================================================================
  // FIREBASE METHODS
  // ============================================================================

  Future<void> getFirebaseDatabase(BuildContext context) async {
    if (!context.mounted) return;

    Provider.of<ProgressData>(context, listen: false).setLoading(1);

    final email = Provider.of<AuthorisationData>(context, listen: false).email;

    if (email.isEmpty) {
      if (context.mounted) {
        Provider.of<ProgressData>(context, listen: false).setLoading(0);
      }
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('paper-data')
          .doc(email.toLowerCase())
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map;

        _avatar = (data['config']['avatar'] ?? email) as String;
        _selectedDefaultDifficulty =
            (data['config']['difficulty'] ?? "Easy") as String;
        _role = (data['config']['role'] ?? "student") as String;
        _totalQuestionsGenerated =
            (data['totalQuestionsGenerated'] ?? 0) as int;
        _totalQuestionsViewed = (data['totalQuestionsViewed'] ?? 0) as int;
        _totalQuestionsCorrect = (data['totalQuestionsCorrect'] ?? 0) as int;
        _totalQuestionsAttempted =
            (data['totalQuestionsAttempted'] ?? 0) as int;
        _totalQuestionsIncorrect =
            (data['totalQuestionsIncorrect'] ?? 0) as int;
        _subjectsAttempted = (data['subjectsAttempted'] ?? []) as List<String>;
        _streak = (data['streak'] ?? 0) as int;
        _badges = (data['badges'] ?? []) as List;
        _coins = (data['coins'] ?? 0) as int;

        _isDataLoaded = true;
        notifyListeners();
      } else {
        _isDataLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      _isDataLoaded = true;
      notifyListeners();
    } finally {
      if (context.mounted) {
        Provider.of<ProgressData>(context, listen: false).setLoading(0);
      }
    }
  }

  void showError(BuildContext context, message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void resetData() {
    _attempted = {};
    _viewed = <int>{};
    _pastPapers = [];
    _correctLocal = 0;
    _totalQuestionsAttempted = 0;
    _avatar = '';
    _isDataLoaded = false;
    _selectedSubject = null;
    notifyListeners();
  }

  // ============================================================================
  // GEMINI API METHODS
  // ============================================================================

  final model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

  String _prompt = '';

  get prompt => _prompt;

  void buildPrompt() {
    if (_selectedSubject == null) return;

    final s = _selectedSubject!;

    final buffer = StringBuffer();
    buffer.writeln(
        "Generate ${s.questionCount} questions for ${s.name} at ${s.difficulty} difficulty in valid JSON array format.");

    buffer.writeln("\nFormat (return ONLY this structure):");
    buffer.write(
        '[{"subject":"${s.name}","difficulty":"${s.difficulty}","questions":[');
    buffer.write('{"question":"What is x² + 2x when x=3?"');
    buffer.write(',"options":["11","13","15","17"]');
    buffer.writeln(',"answer":"15","explanation":"Substitute: 9 + 6 = 15"}');
    buffer.writeln(']}]');

    buffer.writeln("\nRules:");
    buffer.writeln("• Return ONLY JSON array [...]");
    buffer.writeln("• NO markdown/backticks");
    buffer.writeln("• Use ' not \" inside text");
    buffer.writeln("• Math: x² √2 π ½ sin(x) - NO LaTeX/backslashes");
    buffer.writeln("• Brief explanations (1-2 lines)");

    _prompt = buffer.toString();
    notifyListeners();
  }

  List<SubjectQuestions> parseGeminiResponse(String response) {
    try {
      print('📥 Starting to parse response (${response.length} characters)');

      // Clean up response
      String cleanedResponse = response.trim();

      // Remove markdown code blocks
      if (cleanedResponse.contains('```')) {
        cleanedResponse = cleanedResponse
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();
      }

      print('🧹 Cleaned response preview (first 300 chars):');
      print(cleanedResponse.substring(0, min(300, cleanedResponse.length)));
      print('...');

      // Validate JSON structure
      if (!cleanedResponse.startsWith('[')) {
        print('❌ Error: Response does not start with [');
        print(
            'First 100 chars: ${cleanedResponse.substring(0, min(100, cleanedResponse.length))}');
        return [];
      }

      // Parse JSON
      final List<dynamic> jsonList = json.decode(cleanedResponse) as List;
      print('✅ Successfully decoded JSON array with ${jsonList.length} items');

      // Convert to SubjectQuestions objects
      final List<SubjectQuestions> subjects = [];

      for (int i = 0; i < jsonList.length; i++) {
        try {
          print('📝 Processing subject ${i + 1}/${jsonList.length}');
          final subject =
              SubjectQuestions.fromJson(jsonList[i] as Map<String, dynamic>);

          if (subject.questions.isEmpty) {
            print('⚠️ Warning: Subject "${subject.subject}" has no questions');
          } else {
            subjects.add(subject);
            print(
                '✅ Added subject "${subject.subject}" with ${subject.questions.length} questions');
          }
        } catch (e) {
          print('❌ Error parsing subject ${i + 1}: $e');
          continue;
        }
      }

      final totalQuestions = subjects.fold<int>(
          0, (sum, subject) => sum + subject.questions.length);

      print(
          '🎉 Successfully parsed ${subjects.length} subjects with $totalQuestions total questions');

      return subjects;
    } catch (e, stackTrace) {
      return [];
    }
  }

  Future<GeneratedPaper?> generateFromPrompt(context) async {
    if (_selectedSubject == null) {
      print('❌ Error: No subject selected');
      return null;
    }

    try {
      const String apiKey = "AIzaSyAoWmNDwsp0hA0KNejAATbMy6wSAMcPcBs";

      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );

      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": _prompt}
            ]
          }
        ]
      });

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode != 200) {
        showError(context, "❌ Gemini API Error: ${res.body}");
        return null;
      }

      final data = jsonDecode(res.body);

      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (text == null || text.isEmpty) {
        showError(context, 'Error: Empty response from Gemini');
        return null;
      }

      print('✅ Received response from Gemini');

      // Parse the response (unchanged)
      final subjects = parseGeminiResponse(text);

      if (subjects.isEmpty) {
        showError(context, 'Error: No subjects parsed from response');
        return null;
      }

      // Total questions comes directly from the single parsed subject
      final totalQuestions = subjects[0].questions.length;

      final id = generateUniqueId();
      final paper = GeneratedPaper(
        id: id,
        createdAt: DateTime.now(),
        subjects: subjects,
        totalQuestions: totalQuestions,
      );

      try {
        await FirebaseFirestore.instance
            .collection(
                Provider.of<AuthorisationData>(context, listen: false).email)
            .doc(id)
            .set(paper.toJson());
        print('✅ Paper saved to Firebase');
      } catch (e) {
        print('⚠️ Could not save to Firebase: $e');
      }

      // Store the paper locally
      _currentGeneratedPaper = paper;
      _generatedPapers.add(paper);
      notifyListeners();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DisplayQuestionsScreen()));
      print('✅ Successfully generated paper with $totalQuestions questions');
      _totalQuestionsGenerated += _selectedSubject!.questionCount;
      setSubjectsAttempted(_selectedSubject!.name);
      return paper;
    } catch (e) {
      showError(context, "❌ Error generating paper: $e");
      return null;
    }
  }

  GeneratedPaper getDummyPaper() {
    return GeneratedPaper(
      id: '2026_02_01_W5_120000',
      createdAt: DateTime.now(),
      totalQuestions: 10,
      subjects: [
        SubjectQuestions(
          subject: 'Mathematics',
          difficulty: 'Medium',
          questions: [
            Question(
              question: 'What is the value of x² + 3x when x = 4?',
              options: ['24', '28', '30', '32'],
              answer: '28',
              explanation: 'x² = 16, 3x = 12. So 16 + 12 = 28.',
            ),
            Question(
              question: 'What is the area of a circle with radius 5?',
              options: ['25π', '50π', '10π', '75π'],
              answer: '25π',
              explanation: 'Area = πr². So π × 5² = 25π.',
            ),
            Question(
              question: 'Simplify: (2³)²',
              options: ['32', '64', '128', '16'],
              answer: '64',
              explanation: '(2³)² = 2⁶ = 64.',
            ),
            Question(
              question: 'What is 15% of 200?',
              options: ['25', '30', '35', '40'],
              answer: '30',
              explanation: '15% of 200 = (15/100) × 200 = 30.',
            ),
            Question(
              question: 'Solve for x: 2x + 10 = 30',
              options: ['5', '8', '10', '15'],
              answer: '10',
              explanation: '2x = 30 - 10 = 20. So x = 10.',
            ),
          ],
        ),
        SubjectQuestions(
          subject: 'Computer Science',
          difficulty: 'Hard',
          questions: [
            Question(
              question:
                  'What is the time complexity of binary search on a sorted array?',
              options: ['O(n)', 'O(n²)', 'O(log n)', 'O(n log n)'],
              answer: 'O(log n)',
              explanation:
                  'Binary search halves the search space each step, giving logarithmic complexity.',
            ),
            Question(
              question: 'Which data structure is used in BFS?',
              options: ['Stack', 'Queue', 'Linked List', 'Tree'],
              answer: 'Queue',
              explanation:
                  'BFS explores nodes level by level, so it uses a queue to track the order.',
            ),
            Question(
              question: 'What does SQL stand for?',
              options: [
                'Simple Query Language',
                'Structured Query Language',
                'System Query Logic',
                'Sequential Query Language'
              ],
              answer: 'Structured Query Language',
              explanation:
                  'SQL is a standard language for managing and querying relational databases.',
            ),
            Question(
              question:
                  'Which sorting algorithm has an average case complexity of O(n log n)?',
              options: [
                'Bubble Sort',
                'Selection Sort',
                'Merge Sort',
                'Linear Sort'
              ],
              answer: 'Merge Sort',
              explanation:
                  'Merge sort divides the array in half recursively and merges, always O(n log n).',
            ),
            Question(
              question: 'What is the purpose of a stack in memory?',
              options: [
                'Stores global variables',
                'Stores local variables and function calls',
                'Manages heap allocation',
                'Handles network I/O'
              ],
              answer: 'Stores local variables and function calls',
              explanation:
                  'The stack manages local scope — local variables and the call chain of functions.',
            ),
          ],
        ),
      ],
    );
  }

  void saveMetricsToFirebase(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection(
              Provider.of<AuthorisationData>(context, listen: false).email)
          .doc(Provider.of<AuthorisationData>(context, listen: false).email)
          .set({
        "config": {
          "avatar": _avatar,
          "difficulty": _selectedDefaultDifficulty,
          "role": _role
        },
        "totalQuestionsGenerated": _totalQuestionsGenerated,
        "totalQuestionsViewed": _totalQuestionsViewed,
        "totalQuestionsAttempted": _totalQuestionsAttempted,
        "totalQuestionsCorrect": _totalQuestionsCorrect,
        "totalQuestionsIncorrect": _totalQuestionsIncorrect,
        "streak": _streak,
        "subjectsAttempted": _subjectsAttempted,
        "badges": _badges,
        "coins": _coins
      });
      print('✅ Paper saved to Firebase');
    } catch (e) {
      showError(context, '⚠️ Could not save to Firebase: $e');
    }
  }
}
