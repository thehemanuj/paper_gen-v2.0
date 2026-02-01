import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/assets/Button.dart';
import 'package:provider/provider.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';

class GeneratePaperScreen extends StatefulWidget {
  const GeneratePaperScreen({Key? key}) : super(key: key);

  @override
  State<GeneratePaperScreen> createState() => _GeneratePaperScreenState();
}

class _GeneratePaperScreenState extends State<GeneratePaperScreen> {
  bool _showSubjectInput = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QuestionData, ProgressData>(
      builder: (context, questionData, proData, child) {
        return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: FloatingActionButton(
              backgroundColor: Color(0xff26A69A),
              onPressed: () {
                Provider.of<ProgressData>(context, listen: false).setDarkMode();
              },
              child: Icon(
                proData.darkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor:
              proData.darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
          body: ModalProgressHUD(
            progressIndicator: CircularProgressIndicator(
              color: Color(0xff26a69a),
            ),
            inAsyncCall: proData.loading == 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('images/papergen_border_up.png'),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Go Back",
                      style: TextStyle(
                          color: Color(0xff36d0c2),
                          fontSize: 20.0,
                          fontFamily: 'Copper'),
                    )),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInstructionCard(proData),
                        const SizedBox(height: 16),

                        // Subjects List
                        ...questionData.selectedSubjects
                            .map((subject) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildSubjectCard(
                                      context, questionData, proData, subject),
                                ))
                            .toList(),

                        // Add Subject Button/Input
                        if (questionData.canAddMoreSubjects)
                          _buildAddSubjectSection(
                              context, questionData, proData),

                        // Summary Card
                        if (questionData.selectedSubjects.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildSummaryCard(questionData),
                        ],

                        const SizedBox(height: 100), // Space for button
                      ],
                    ),
                  ),
                ),

                // Generate Button
                _buildGenerateButton(context, questionData),
                SizedBox(
                  height: 50.0,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionCard(proData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: proData.darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1ABC9C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.book_outlined,
              color: Color(0xFF36d0c2),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Your Custom Paper',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF26d0c2),
                      fontFamily: 'Copper'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add up to 5 subjects, select difficulty level, and set the number of questions for each subject.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                      fontFamily: 'Copper'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, QuestionData questionData,
      proData, SubjectConfig subject) {
    final difficultyLevels = [
      'Easy',
      'Medium',
      'Hard',
      'Extreme',
      'Professional',
      'God'
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: proData.darkMode ? Color(0xff0A0E27) : Color(0xffFDFBF7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF36d0c2),
                      fontFamily: 'Copper'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => questionData.removeSubject(subject.id),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Difficulty Selection
          const Text(
            'Difficulty Level',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
                fontFamily: 'Copper'),
          ),
          const SizedBox(height: 8),
          Row(
            children: difficultyLevels.map((level) {
              final isSelected = subject.difficulty == level;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () =>
                        questionData.updateSubjectDifficulty(subject.id, level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF36d0c2)
                            : proData.darkMode
                                ? const Color(0xff0a0e27)
                                : const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF1ABC9C).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        level,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF7F8C8D),
                            fontFamily: 'Copper'),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Questions Count
          const Text(
            'Number of Questions',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
                fontFamily: 'Copper'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Minus Button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove,
                      color: Color(0xFF1ABC9C), size: 20),
                  onPressed: () {
                    questionData.updateSubjectQuestionCount(
                        subject.id, subject.questionCount - 5);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Number Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: proData.darkMode
                        ? Color(0xff0a0e27)
                        : Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF36d0c2),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${subject.questionCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF36d0c2),
                        fontFamily: 'copper'),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Plus Button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.add, color: Color(0xFF1ABC9C), size: 20),
                  onPressed: () {
                    questionData.updateSubjectQuestionCount(
                        subject.id, subject.questionCount + 5);
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                  activeColor: Color(0xff36d0c2),
                  value: subject.needOption,
                  onChanged: (value) {
                    questionData.checkbox(subject.id, value);
                  }),
              Text(
                'Need options',
                style:
                    TextStyle(color: Color(0xff36d0c2), fontFamily: 'copper'),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAddSubjectSection(
      BuildContext context, QuestionData questionData, proData) {
    if (!_showSubjectInput) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Color(0xff36d0c2)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _showSubjectInput = true;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                _searchFocusNode.requestFocus();
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color(0xFF1ABC9C)),
                  const SizedBox(width: 8),
                  Text(
                    'Add Subject (${questionData.selectedSubjects.length}/${questionData.maxSubjects})',
                    style: const TextStyle(
                        color: Color(0xFF1ABC9C),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'copper'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Input
          TextField(
            style: TextStyle(
              color: proData.darkMode ? Colors.white : Colors.black,
            ),
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              focusColor: proData.darkMode ? Colors.white : Colors.teal,
              hintText: 'Search subjects...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1ABC9C)),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE8E9ED),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1ABC9C),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),

          // Suggestions - Only show available subjects from the list
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: () {
                final filtered =
                    questionData.getFilteredSubjects(_searchController.text);

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No matching subjects found',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView(
                  shrinkWrap: true,
                  children: filtered
                      .map((subject) => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                questionData.addSubject(subject);
                                _searchController.clear();
                                setState(() {
                                  _showSubjectInput = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Text(
                                  subject,
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                );
              }(),
            ),
          ] else ...[
            // Show all available subjects when search is empty
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: () {
                final availableSubjects = questionData.getFilteredSubjects('');

                if (availableSubjects.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'All subjects have been added',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView(
                  shrinkWrap: true,
                  children: availableSubjects
                      .map((subject) => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                questionData.addSubject(subject);
                                _searchController.clear();
                                setState(() {
                                  _showSubjectInput = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Text(
                                  subject,
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                );
              }(),
            ),
          ],

          // Cancel Button
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _showSubjectInput = false;
              });
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(QuestionData questionData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Questions:',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff26a69a),
                    fontFamily: 'copper'),
              ),
              Text(
                '${questionData.totalQuestions}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26a69a),
                    fontFamily: 'copper'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subjects Added:',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFff26a69a),
                    fontFamily: 'copper'),
              ),
              Text(
                '${questionData.selectedSubjects.length}/${questionData.maxSubjects}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26a69a),
                    fontFamily: 'copper'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, QuestionData questionData) {
    final hasSubjects = questionData.selectedSubjects.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: MyButton(
          'Generate Paper',
          hasSubjects
              ? () async {
                  Provider.of<ProgressData>(context, listen: false)
                      .setLoading(1);
                  try {
                    questionData.buildPrompt();
                    print('Generating paper...');
                    await questionData.generateFromPrompt(context);

                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    Provider.of<ProgressData>(context, listen: false)
                        .setLoading(0);
                  }
                }
              : null,
          1),
    );
  }
}
