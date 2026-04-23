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

import '../screens/assessment/FinalQuestionScreen.dart';

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

  final Map<String, List<String>> _availableSubjects = {
    "GATE-CSE/IT": [
      "Engineering Mathematics",
      "Digital Logic",
      "Computer Organization",
      "Programming & Data Structures",
      "Algorithms",
      "Theory of Computation",
      "Compiler Design",
      "Operating System",
      "Databases",
      "Computer Networks"
    ],
    "GATE-EC": [
      "General Aptitude",
      "Engineering Mathematics",
      "Networks",
      "Signals and Systems",
      "Electronic Devices",
      "Analog Circuits",
      "Digital Circuits",
      "Control Systems",
      "Communications",
      "Electromagnetics"
    ],
    "GATE-MECHANICAL": [
      "General Aptitude",
      "Engineering Mathematics",
      "Applied Mechanics and Design",
      "Fluid Mechanics and Thermal Sciences",
      "Materials, Manufacturing and Industrial Engineering"
    ],
    "JEE-MAINS": ["Physics", "Chemistry", "Mathematics"],
    "NEET": ["Physics", "Chemistry", "Biology"],
    "CLAT": [
      "English Language",
      "Logical Reasoning",
      "Legal Reasoning",
      "General Knowledge",
      "Current Affairs",
      "Quantitative Techniques"
    ],
    "NDA": [
      "Mathematics",
      "English",
      "General Knowledge",
      "Physics",
      "Chemistry",
      "Biology",
      "History",
      "Geography",
      "Current Affairs"
    ],
  };

  final Map<String, List<Map<String, String>>> availableSubjectsWithLinks = {
    "GATE-CSE/IT": [
      {
        "subject": "Engineering Mathematics",
        "url": "https://www.youtube.com/watch?v=h4sd7wRcyR0"
      },
      {
        "subject": "Digital Logic",
        "url": "https://www.youtube.com/watch?v=lH0sYax5Yg0"
      },
      {
        "subject": "Computer Organization",
        "url": "https://www.youtube.com/watch?v=nezosHntjPg"
      },
      {
        "subject": "Programming & Data Structures",
        "url": "https://www.youtube.com/watch?v=2o2vX0ZqQ_Y"
      },
      {
        "subject": "Algorithms",
        "url": "https://www.youtube.com/watch?v=aaHL0KygWqE"
      },
      {
        "subject": "Theory of Computation",
        "url": "https://www.youtube.com/watch?v=gK_V_lzNQg8"
      },
      {
        "subject": "Compiler Design",
        "url": "https://www.youtube.com/watch?v=7Tq2Amm15g8"
      },
      {
        "subject": "Operating System",
        "url": "https://www.youtube.com/watch?v=009FHqBo87Q"
      },
      {
        "subject": "Databases",
        "url": "https://www.youtube.com/watch?v=FchQ6wZVqsA"
      },
      {
        "subject": "Computer Networks",
        "url": "https://www.youtube.com/watch?v=APVCgkqWcQ4"
      },
    ],
    "GATE-EC": [
      {
        "subject": "General Aptitude",
        "url": "https://www.youtube.com/watch?v=wtGav_k3Q4Y"
      },
      {
        "subject": "Engineering Mathematics",
        "url": "https://www.youtube.com/watch?v=R_QS-WyCg5M"
      },
      {
        "subject": "Networks",
        "url": "https://www.youtube.com/watch?v=wO-f7l9l-E0"
      },
      {
        "subject": "Signals and Systems",
        "url": "https://www.youtube.com/watch?v=EKIn5izyfSU"
      },
      {
        "subject": "Electronic Devices",
        "url": "https://www.youtube.com/watch?v=_kokAMWAwKc"
      },
      {
        "subject": "Analog Circuits",
        "url": "https://www.youtube.com/watch?v=39Lsz6pFGRo"
      },
      {
        "subject": "Digital Circuits",
        "url": "https://www.youtube.com/watch?v=neohkz23NXA"
      },
      {
        "subject": "Control Systems",
        "url": "https://www.youtube.com/watch?v=Nn77UkbQUwo"
      },
      {
        "subject": "Communications",
        "url": "https://www.youtube.com/live/tJJ09wIiZc0"
      },
      {
        "subject": "Electromagnetics",
        "url": "https://www.youtube.com/watch?v=MaotyqxrQUc"
      },
    ],
    "GATE-MECHANICAL": [
      {
        "subject": "General Aptitude",
        "url": "https://www.youtube.com/watch?v=wtGav_k3Q4Y"
      },
      {
        "subject": "Engineering Mathematics",
        "url": "https://www.youtube.com/watch?v=BESBmRGW1Us"
      },
      {
        "subject": "Applied Mechanics and Design",
        "url": "https://www.youtube.com/watch?v=5KFbOcBNNQY"
      },
      {
        "subject": "Fluid Mechanics and Thermal Sciences",
        "url": "https://www.youtube.com/watch?v=5KFbOcBNNQY"
      },
      {
        "subject": "Materials, Manufacturing and Industrial Engineering",
        "url": "https://www.youtube.com/watch?v=5KFbOcBNNQY"
      },
    ],
    "JEE-MAINS": [
      {
        "subject": "Physics",
        "url": "https://www.youtube.com/watch?v=dtsNdJwAs7E"
      },
      {
        "subject": "Chemistry",
        "url": "https://www.youtube.com/watch?v=mInr_sDhX5E"
      },
      {
        "subject": "Mathematics",
        "url": "https://www.youtube.com/watch?v=Xn4HdX9i3yA"
      },
    ],
    "NEET": [
      {
        "subject": "Physics",
        "url": "https://www.youtube.com/watch?v=3znerIFcpPY"
      },
      {
        "subject": "Chemistry",
        "url": "https://www.youtube.com/watch?v=jNOy11yq0gU"
      },
      {
        "subject": "Biology",
        "url": "https://www.youtube.com/watch?v=UROAHKW91Us"
      },
    ],
    "CLAT": [
      {
        "subject": "English Language",
        "url": "https://www.youtube.com/watch?v=X8m427BuSQ8"
      },
      {
        "subject": "Logical Reasoning",
        "url": "https://www.youtube.com/watch?v=X8m427BuSQ8"
      },
      {
        "subject": "Legal Reasoning",
        "url": "https://www.youtube.com/watch?v=w8EpSJHvLw4"
      },
      {
        "subject": "General Knowledge",
        "url": "https://www.youtube.com/watch?v=gQf0P59BiJU"
      },
      {
        "subject": "Current Affairs",
        "url": "https://www.youtube.com/watch?v=gQf0P59BiJU"
      },
      {
        "subject": "Quantitative Techniques",
        "url": "https://www.youtube.com/watch?v=EvFhWd0oUXY"
      },
    ],
    "NDA": [
      {
        "subject": "Mathematics",
        "url": "https://www.youtube.com/watch?v=Xn4HdX9i3yA"
      },
      {
        "subject": "English",
        "url": "https://www.youtube.com/watch?v=X8m427BuSQ8"
      },
      {
        "subject": "General Knowledge",
        "url": "https://www.youtube.com/watch?v=gQf0P59BiJU"
      },
      {
        "subject": "Physics",
        "url": "https://www.youtube.com/watch?v=dtsNdJwAs7E"
      },
      {
        "subject": "Chemistry",
        "url": "https://www.youtube.com/watch?v=mInr_sDhX5E"
      },
      {
        "subject": "Biology",
        "url": "https://www.youtube.com/watch?v=UROAHKW91Us"
      },
      {
        "subject": "History",
        "url": "https://www.youtube.com/watch?v=gQf0P59BiJU"
      },
      {
        "subject": "Geography",
        "url": "https://www.youtube.com/watch?v=gQf0P59BiJU"
      },
      {
        "subject": "Current Affairs",
        "url": "https://www.youtube.com/watch?v=gQf0P59BiJU"
      },
    ],
  };

  String extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    if (uri.host.contains('youtu.be')) return uri.pathSegments.first;
    if (uri.pathSegments.contains('live')) {
      return uri.pathSegments[uri.pathSegments.indexOf('live') + 1];
    }
    return uri.queryParameters['v'] ?? '';
  }

  List<Map<String, String>> get allLearnVideos {
    final List<Map<String, String>> result = [];
    availableSubjectsWithLinks.forEach((exam, subjects) {
      for (final s in subjects) {
        result.add({
          'videoId': extractVideoId(s['url'] ?? ''),
          'title': s['subject'] ?? '',
          'channelName': exam,
          'subject': exam,
          'url': s['url'] ?? '',
        });
      }
    });
    return result;
  }

  List<Map<String, String>> videosForExam(String exam) {
    return (availableSubjectsWithLinks[exam] ?? [])
        .map((s) => {
              'videoId': extractVideoId(s['url'] ?? ''),
              'title': s['subject'] ?? '',
              'channelName': exam,
              'subject': exam,
              'url': s['url'] ?? '',
            })
        .toList();
  }

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

  final _examList = [
    "GATE-CSE/IT",
    "GATE-EC",
    "GATE-MECHANICAL",
    "JEE-MAINS",
    "NEET",
    "CLAT",
    "NDA",
  ];

  final int _maxQuestionsAllowed = 100;

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  var _avatar = "";
  var _config = Map<int, int>();
  var _totalQuestionsGenerated = 0;
  var _totalQuestionsViewed = 0;
  var _totalQuestionsAttempted = 0;
  var _totalQuestionsCorrect = 0;
  var _totalQuestionsIncorrect = 0;
  var _subjectsAttempted = [];
  var _streak = 0;
  var _badges = [];
  var _role = "student";
  var _coins = 0;
  var _pastPapers = [];
  var _correctLocal = 0;
  var _attempted = Map<int, int>();
  bool _isDataLoaded = false;
  String _selectedDefaultDifficulty = 'Easy';
  var _selectedDifficulty = '';

  SubjectConfig? _selectedSubject;
  GeneratedPaper? _currentGeneratedPaper;
  final List<GeneratedPaper> _generatedPapers = [];
  var _viewed = <int>{0};
  bool _timerEnabled = false;
  int _timerSeconds = 10;

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<String> get examList => _examList;
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
  String get selectedDefaultDifficulty => _selectedDefaultDifficulty;
  String get selectedDifficulty => _selectedDifficulty;

  SubjectConfig? get selectedSubject => _selectedSubject;
  GeneratedPaper? get currentGeneratedPaper => _currentGeneratedPaper;
  List<GeneratedPaper> get generatedPapers => _generatedPapers;
  Set<int> get viewed => _viewed;
  List<String>? get availableSubjects => _availableSubjects[selectedExam];

  int get maxQuestionsAllowed => _maxQuestionsAllowed;
  bool get isSubjectSelected => _selectedSubject != null;
  int get totalQuestions => _selectedSubject?.questionCount ?? 0;
  get difficultyList => _difficultyList;
  bool get timerEnabled => _timerEnabled;
  int get timerSeconds => _timerSeconds;

  // ============================================================================
  // USER DATA METHODS
  // ============================================================================

  String? selectedExam = "JEE-MAINS";
  String? preparationLevel;
  double dailyStudyHours = 1.0;
  DateTime? examDate;

  void setSelectedExam(String exam) {
    selectedExam = exam;
    notifyListeners();
  }

  void setPreparationLevel(String level) {
    preparationLevel = level;
    notifyListeners();
  }

  void setDailyStudyHours(double hours) {
    dailyStudyHours = hours;
    notifyListeners();
  }

  void setExamDate(DateTime date) {
    examDate = date;
    notifyListeners();
  }

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
    String seed = _avatar.isNotEmpty ? _avatar : 'paper-gen';
    String image = multiavatar(seed);
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

  bool deductCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      notifyListeners();
      return true;
    }
    return false;
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

  void setTimerEnabled(bool value) {
    _timerEnabled = value;
    notifyListeners();
  }

  void setTimer(int seconds) {
    _timerSeconds = (_timerSeconds + seconds).clamp(10, 300);
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

  String _getDifficultyByPrepLevel() {
    if (preparationLevel == 'Beginner') return 'Hard';
    if (preparationLevel == 'Intermediate') return 'Expert';
    return 'Professional'; // Advanced or default
  }

  void selectSubject(String subjectName) {
    _selectedSubject = SubjectConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: subjectName,
      difficulty: _getDifficultyByPrepLevel(),
      questionCount: 10,
    );
    notifyListeners();
  }

  void clearSelectedSubject() {
    _selectedSubject = null;
    notifyListeners();
  }

  void updateDifficulty(String difficulty) {
    if (_selectedSubject == null) return;
    _selectedSubject!.difficulty = difficulty;
    notifyListeners();
  }

  void updateQuestionCount(int count) {
    if (_selectedSubject == null) return;
    _selectedSubject!.questionCount = count.clamp(1, _maxQuestionsAllowed);
    notifyListeners();
  }

  List<String>? getFilteredSubjects(String query) {
    final subjects = _availableSubjects[selectedExam];
    if (subjects == null) return null;

    final lowerQuery = query.toLowerCase();
    return subjects
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
    final dayOfYear = int.parse(DateFormat("D").format(now));
    final weekOfYear = ((dayOfYear - now.weekday + 10) / 7).floor();
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
          .collection(email.toLowerCase())
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
        _subjectsAttempted = (data['subjectsAttempted'] ?? []) as List;
        _streak = (data['streak'] ?? 0) as int;
        _badges = (data['badges'] ?? []) as List;
        _coins = (data['coins'] ?? 0) as int;
      }

      QuerySnapshot pastPapersSnapshot = await FirebaseFirestore.instance
          .collection(email.toLowerCase())
          .get();

      _pastPapers = pastPapersSnapshot.docs
          .where((doc) => doc.id != email.toLowerCase())
          .map((doc) =>
              GeneratedPaper.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      await fetchSelectedSubject(context);
      _isDataLoaded = true;
      notifyListeners();
    } catch (e) {
      _isDataLoaded = true;
      showError(context, e.toString());
      notifyListeners();
    } finally {
      if (context.mounted) {
        Provider.of<ProgressData>(context, listen: false).setLoading(0);
      }
    }
  }

  Future<void> fetchSelectedSubject(BuildContext context) async {
    var email = Provider.of<AuthorisationData>(context, listen: false).email;
    if (email.isEmpty) return;

    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('user_plans')
        .doc(email.toLowerCase())
        .get();

    if (doc.exists) {
      selectedExam = doc.data()?['selectedExam'] ?? "JEE-MAINS";
      preparationLevel = doc.data()?['preparationLevel'] ?? "Beginner";
      notifyListeners();
    }
  }

  void showError(BuildContext context, message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void resetData() {
    _attempted = {};
    _viewed = <int>{0};
    _correctLocal = 0;
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
    buffer.writeln("• Use ' not \" inside text");
    buffer.writeln("• Produce exactly 4 options");
    buffer.writeln("• NO markdown/backticks");
    buffer.writeln("• Math: x² √2 π ½ sin(x) - NO LaTeX/backslashes");
    buffer.writeln("• Brief explanations (1-2 lines)");
    _prompt = buffer.toString();
    notifyListeners();
  }

  List<SubjectQuestions> parseGeminiResponse(String response) {
    try {
      String cleanedResponse = response.trim();
      if (cleanedResponse.contains('```')) {
        cleanedResponse = cleanedResponse
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();
      }
      if (!cleanedResponse.startsWith('[')) return [];
      final List<dynamic> jsonList = json.decode(cleanedResponse) as List;
      final List<SubjectQuestions> subjects = [];
      for (int i = 0; i < jsonList.length; i++) {
        try {
          final subject =
              SubjectQuestions.fromJson(jsonList[i] as Map<String, dynamic>);
          if (subject.questions.isNotEmpty) {
            subjects.add(subject);
          }
        } catch (e) {
          continue;
        }
      }
      return subjects;
    } catch (e) {
      return [];
    }
  }

  Future<GeneratedPaper?> generateFromPrompt(context) async {
    if (_selectedSubject == null) return null;
    try {
      const String apiKey = "AIzaSyDE_vbho_yrUmysFOzzVrUT0QX9Xjs6sQM";
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
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
      if (res.statusCode != 200) {
        showError(context, "❌ Gemini API Error");
        return null;
      }
      final data = jsonDecode(res.body);
      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
      if (text == null || text.isEmpty) return null;
      final subjects = parseGeminiResponse(text);
      if (subjects.isEmpty) return null;
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
      } catch (e) {}
      _currentGeneratedPaper = paper;
      _generatedPapers.add(paper);

      // Award 10 coins per question generated
      setCoins(totalQuestions * 10);

      notifyListeners();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const DisplayQuestionsScreen()));
      _totalQuestionsGenerated += _selectedSubject!.questionCount;
      setSubjectsAttempted(_selectedSubject!.name);
      return paper;
    } catch (e) {
      showError(context, "❌ Error generating paper: $e");
      return null;
    }
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
    } catch (e) {}
  }

  Future<void> saveUserPlanToFirestore(context) async {
    await FirebaseFirestore.instance
        .collection('user_plans')
        .doc(Provider.of<AuthorisationData>(context, listen: false).email)
        .set({
      'selectedExam': selectedExam,
      'preparationLevel': preparationLevel,
      'dailyStudyHours': dailyStudyHours,
      'examDate': examDate != null ? Timestamp.fromDate(examDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    fetchSelectedSubject(context);
  }
}
