class Question {
  final String question;
  final List<String>? options;
  final String answer;
  final String? explanation;

  Question({
    required this.question,
    this.options,
    required this.answer,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      return Question(
        question: json['question']?.toString() ?? '',
        options: json['options'] != null
            ? (json['options'] as List).map((e) => e.toString()).toList()
            : null,
        answer: json['answer']?.toString() ?? '',
        explanation: json['explanation']?.toString(),
      );
    } catch (e) {
      print('❌ Error parsing Question: $e');
      print('Question JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'question': question,
      'answer': answer,
    };

    if (options != null) {
      data['options'] = options;
    }

    if (explanation != null) {
      data['explanation'] = explanation;
    }

    return data;
  }
}

class SubjectQuestions {
  final String subject;
  final String difficulty;
  final List<Question> questions;

  SubjectQuestions({
    required this.subject,
    required this.difficulty,
    required this.questions,
  });

  factory SubjectQuestions.fromJson(Map<String, dynamic> json) {
    try {
      print('📖 Parsing subject: ${json['subject']}');

      final questionsList = json['questions'] as List?;
      if (questionsList == null || questionsList.isEmpty) {
        print('⚠️ No questions found for subject: ${json['subject']}');
      }

      final parsedQuestions = questionsList
              ?.map((q) {
                try {
                  return Question.fromJson(q as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Failed to parse question: $e');
                  return null;
                }
              })
              .whereType<Question>() // Filter out nulls
              .toList() ??
          [];

      print(
          '✅ Parsed ${parsedQuestions.length} questions for ${json['subject']}');

      return SubjectQuestions(
        subject: json['subject']?.toString() ?? 'Unknown',
        difficulty: json['difficulty']?.toString() ?? 'Medium',
        questions: parsedQuestions,
      );
    } catch (e) {
      print('❌ Error parsing SubjectQuestions: $e');
      print('Subject JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class GeneratedPaper {
  final String id;
  final DateTime createdAt;
  final List<SubjectQuestions> subjects;
  final int totalQuestions;

  GeneratedPaper({
    required this.id,
    required this.createdAt,
    required this.subjects,
    required this.totalQuestions,
  });

  factory GeneratedPaper.fromJson(Map<String, dynamic> json) {
    try {
      final subjectsList = json['subjects'] as List?;
      final parsedSubjects = subjectsList
              ?.map((s) {
                try {
                  return SubjectQuestions.fromJson(s as Map<String, dynamic>);
                } catch (e) {
                  print('❌ Failed to parse subject: $e');
                  return null;
                }
              })
              .whereType<SubjectQuestions>()
              .toList() ??
          [];

      return GeneratedPaper(
        id: json['id']?.toString() ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
        subjects: parsedSubjects,
        totalQuestions: json['totalQuestions'] as int? ?? 0,
      );
    } catch (e) {
      print('❌ Error parsing GeneratedPaper: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'totalQuestions': totalQuestions,
    };
  }
}
