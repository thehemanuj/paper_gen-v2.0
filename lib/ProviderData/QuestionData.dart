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
  bool needOption;

  SubjectConfig({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.questionCount,
    required this.needOption,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'questionCount': questionCount,
      'needOption': needOption,
    };
  }

  factory SubjectConfig.fromMap(Map<String, dynamic> map) {
    return SubjectConfig(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      questionCount: map['questionCount'] ?? 10,
      needOption: map['needOption'] ?? false,
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

  final int _maxSubjects = 5;
  final int _maxQuestionsAllowed = 99;

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  // User data
  var _pastPapers = [];
  var _correct = 0;
  var _totalQuestionsAttempted = 0;
  var _subjects = [];
  var _avatar = '';
  bool _isDataLoaded = false;

  // Difficulty settings
  String _selectedDefaultDifficulty = 'Easy';
  var _selectedDifficulty = '';

  // Paper generation
  final List<SubjectConfig> _selectedSubjects = [];
  GeneratedPaper? _currentGeneratedPaper;
  final List<GeneratedPaper> _generatedPapers = [];

  // ============================================================================
  // GETTERS
  // ============================================================================

  // User data getters
  bool get isDataLoaded => _isDataLoaded;

  get pastPapers => _pastPapers;

  get correct => _correct;

  get totalAttempted => _totalQuestionsAttempted;

  get subjects => _subjects;

  // Difficulty getters
  get selectedDefaultDifficulty => _selectedDefaultDifficulty;

  get difficultyList => _difficultyList;

  get selectedDifficulty => _selectedDifficulty;

  // Paper generation getters
  List<String> get availableSubjects => _availableSubjects;

  List<SubjectConfig> get selectedSubjects => _selectedSubjects;

  int get maxSubjects => _maxSubjects;

  int get maxQuestionsAllowed => _maxQuestionsAllowed;

  GeneratedPaper? get currentGeneratedPaper => _currentGeneratedPaper;

  List<GeneratedPaper> get generatedPapers => _generatedPapers;

  bool get canAddMoreSubjects =>
      _selectedSubjects.length < _maxSubjects &&
      _selectedSubjects.fold(
              0, (sum, subject) => sum + subject.questionCount) <=
          _maxQuestionsAllowed;

  int get totalQuestions =>
      _selectedSubjects.fold(0, (sum, subject) => sum + subject.questionCount);

  // ============================================================================
  // USER DATA METHODS
  // ============================================================================

  setCorrect() {
    _correct += 1;
    notifyListeners();
  }

  setTotalQuestionsAttempted() {
    _totalQuestionsAttempted += 1;
    notifyListeners();
  }

  getImage() {
    String image = multiavatar(_avatar);
    return image;
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

  void addSubject(String subjectName) {
    if (_selectedSubjects.length >= _maxSubjects) return;
    if (_selectedSubjects.any((s) => s.name == subjectName)) return;
    if (totalQuestions > _maxQuestionsAllowed) return;

    _selectedSubjects.add(SubjectConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: subjectName,
      difficulty: 'Medium',
      questionCount: 10,
      needOption: false,
    ));
    notifyListeners();
  }

  void removeSubject(String id) {
    _selectedSubjects.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void updateSubjectDifficulty(String id, String difficulty) {
    final index = _selectedSubjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      _selectedSubjects[index].difficulty = difficulty;
      notifyListeners();
    }
  }

  void updateSubjectQuestionCount(String id, int count) {
    final index = _selectedSubjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      _selectedSubjects[index].questionCount = count.clamp(1, 50);
      notifyListeners();
    }
  }

  void checkbox(String id, value) {
    final index = _selectedSubjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      _selectedSubjects[index].needOption = value;
      notifyListeners();
    }
  }

  void clearSelectedSubjects() {
    _selectedSubjects.clear();
    notifyListeners();
  }

  List<String> getFilteredSubjects(String query) {
    final lowerQuery = query.toLowerCase();
    return _availableSubjects
        .where((subject) =>
            subject.toLowerCase().contains(lowerQuery) &&
            !_selectedSubjects.any((s) => s.name == subject))
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

        _avatar = (data['avatar'] ?? email) as String;
        _correct = (data['correctQuestions'] ?? 0) as int;
        _totalQuestionsAttempted = (data['totalQuestions'] ?? 0) as int;
        _pastPapers = (data['pastPapers'] ?? []) as List;
        _subjects = (data['subjects'] ?? []) as List;
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

  void resetData() {
    _pastPapers = [];
    _correct = 0;
    _totalQuestionsAttempted = 0;
    _subjects = [];
    _avatar = '';
    _isDataLoaded = false;
    _selectedSubjects.clear();
    notifyListeners();
  }

  // ============================================================================
  // GEMINI API METHODS
  // ============================================================================

  final model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash-lite');

  String _prompt = '';

  get prompt => _prompt;

  void buildPrompt() {
    final hasOptions = _selectedSubjects.any((s) => s.needOption);
    final totalQs =
        _selectedSubjects.fold(0, (sum, s) => sum + s.questionCount);

    final buffer = StringBuffer();
    buffer.writeln("Generate $totalQs questions in valid JSON array format.");
    buffer.writeln("\nSubjects:");
    for (var s in _selectedSubjects) {
      buffer.writeln(
          "${s.name}: ${s.difficulty}, ${s.questionCount}q${s.needOption ? ', +options' : ''}");
    }

    buffer.writeln("\nFormat (return ONLY this structure):");
    buffer.write('[{"subject":"Math","difficulty":"Medium","questions":[');
    buffer.write('{"question":"What is x² + 2x when x=3?"');
    if (hasOptions) buffer.write(',"options":["11","13","15","17"]');
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
          // Continue to next subject instead of failing completely
          continue;
        }
      }

      final totalQuestions = subjects.fold<int>(
          0, (sum, subject) => sum + subject.questions.length);

      print(
          '🎉 Successfully parsed ${subjects.length} subjects with $totalQuestions total questions');

      return subjects;
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR in parseGeminiResponse: $e');
      print('Stack trace: $stackTrace');
      print('─── Full Response ───');
      print(response);
      print('─────────────────────');
      return [];
    }
  }

  Future<GeneratedPaper?> generateFromPrompt(context) async {
    try {
      final promptToSend = [Content.text(_prompt)];

      // Generate content from Gemini
      final response = await model.generateContent(promptToSend);
      if (response.text == null || response.text!.isEmpty) {
        print('Error: Empty response from Gemini');
        return null;
      }

      print('✅ Received response from Gemini');
      //print(response.text);

      // Parse the response
      final subjects = parseGeminiResponse(response.text!);

      if (subjects.isEmpty) {
        print('Error: No subjects parsed from response');
        return null;
      }

      // Calculate total questions
      int totalQuestions = 0;
      for (var subject in subjects) {
        totalQuestions += subject.questions.length;
      }

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
        // Continue anyway, we have the paper in memory
      }

      // Store the paper locally
      _currentGeneratedPaper = paper;
      _generatedPapers.add(paper);
      notifyListeners();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DisplayQuestionsScreen()));
      print('✅ Successfully generated paper with $totalQuestions questions');

      return paper;
    } catch (e) {
      print("❌ Error generating paper: $e");
      return null;
    }
  }
}
