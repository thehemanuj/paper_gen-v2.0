import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/ProgressData.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:paper_gen/screens/dashboard/WelcomeScreen.dart';
import 'package:provider/provider.dart';

class AskPaperScreen extends StatefulWidget {
  const AskPaperScreen({super.key});

  @override
  State<AskPaperScreen> createState() => _AskPaperScreenState();
}

class _AskPaperScreenState extends State<AskPaperScreen> {
  int _currentStep = 0; // 0,1,2,3 = 4 steps total
  bool _isSaving = false;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<double> _studyHoursOptions = [1, 2, 3, 4, 5, 6, 7, 8];

  // Temp local selections before saving
  String? _tempExam;
  String? _tempLevel;
  double? _tempHours;
  int? _tempDaysLeft; // days left for exam

  final TextEditingController _daysController = TextEditingController();

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validation before moving forward
    if (_currentStep == 0 && _tempExam == null) {
      _showSnack("Please select an exam");
      return;
    }
    if (_currentStep == 1 && _tempLevel == null) {
      _showSnack("Please select a preparation level");
      return;
    }
    if (_currentStep == 2 && _tempHours == null) {
      _showSnack("Please select study hours");
      return;
    }
    if (_currentStep == 3) {
      final parsed = int.tryParse(_daysController.text.trim());
      if (parsed == null || parsed <= 0) {
        _showSnack("Please enter a valid number of days");
        return;
      }
      _tempDaysLeft = parsed;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _saveData() async {
    // Parse days if not already parsed
    final parsed = int.tryParse(_daysController.text.trim());
    if (parsed == null || parsed <= 0) {
      _showSnack("Please enter a valid number of days");
      return;
    }
    _tempDaysLeft = parsed;

    setState(() => _isSaving = true);

    final progressData = Provider.of<ProgressData>(context, listen: false);
    final questionData = Provider.of<QuestionData>(context, listen: false);
    // Push to provider
    questionData.setSelectedExam(_tempExam!);
    questionData.setPreparationLevel(_tempLevel!);
    questionData.setDailyStudyHours(_tempHours!);
    questionData.setExamDate(
      DateTime.now().add(Duration(days: _tempDaysLeft!)),
    );

    // Save to Firestore — pass your actual userId
    try {
      await questionData.saveUserPlanToFirestore(context);
      _showSnack("Saved successfully!");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
    } catch (e) {
      _showSnack("Error saving: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ─── Step Widgets ──────────────────────────────────────────────

  Widget _buildStepExam(QuestionData quesData, bool darkMode) {
    return Column(
      children: [
        _stepTitle("Which exam are you preparing for?", darkMode),
        const SizedBox(height: 12),
        ...quesData.examList.map((exam) {
          final selected = _tempExam == exam;
          return _OptionCard(
            label: exam,
            selected: selected,
            darkMode: darkMode,
            onTap: () => setState(() => _tempExam = exam),
          );
        }),
      ],
    );
  }

  Widget _buildStepLevel(bool darkMode) {
    return Column(
      children: [
        _stepTitle("What is your preparation level?", darkMode),
        const SizedBox(height: 12),
        ..._levels.map((level) {
          final selected = _tempLevel == level;
          return _OptionCard(
            label: level,
            selected: selected,
            darkMode: darkMode,
            onTap: () => setState(() => _tempLevel = level),
          );
        }),
      ],
    );
  }

  Widget _buildStepHours(bool darkMode) {
    return Column(
      children: [
        _stepTitle("How many hours can you study per day?", darkMode),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _studyHoursOptions.map((h) {
            final selected = _tempHours == h;
            return GestureDetector(
              onTap: () => setState(() => _tempHours = h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xff26a69a)
                      : (darkMode
                          ? const Color(0xff1A1E37)
                          : const Color(0xffEFEDE8)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        selected ? const Color(0xff26a69a) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    "${h.toInt()}h",
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : (darkMode ? Colors.white70 : Colors.black87),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStepDays(bool darkMode) {
    return Column(
      children: [
        _stepTitle("How many days are left for your exam?", darkMode),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TextField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "e.g. 90",
              hintStyle: TextStyle(
                color: darkMode ? Colors.white38 : Colors.black38,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xff26a69a), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xff26a69a), width: 2.5),
              ),
              suffixText: "days",
              suffixStyle: const TextStyle(color: Color(0xff26a69a)),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────

  Widget _stepTitle(String text, bool darkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: darkMode ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Copper',
        ),
      ),
    );
  }

  // ─── Progress Indicator ───────────────────────────────────────

  Widget _buildStepIndicator(bool darkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final active = index == _currentStep;
        final done = index < _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: (active || done)
                ? const Color(0xff26a69a)
                : (darkMode ? Colors.white24 : Colors.black26),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressData, QuestionData>(
      builder: (context, proData, quesData, child) {
        final darkMode = proData.darkMode;

        return Scaffold(
          backgroundColor:
              darkMode ? const Color(0xff0A0E27) : const Color(0xffFDFBF7),
          body: Column(
            children: [
              // ── TOP (stays fixed) ──────────────────────────────
              Image.asset('images/papergen_border_up.png'),
              const Text(
                "Set Up Your Plan",
                style: TextStyle(
                  color: Color(0xff26a69a),
                  fontSize: 30.0,
                  fontFamily: 'Copper',
                ),
              ),
              const SizedBox(height: 8),
              _buildStepIndicator(darkMode),
              const SizedBox(height: 16),

              // ── MIDDLE (scrollable, changes per step) ──────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(_currentStep),
                      child: _currentStep == 0
                          ? _buildStepExam(quesData, darkMode)
                          : _currentStep == 1
                              ? _buildStepLevel(darkMode)
                              : _currentStep == 2
                                  ? _buildStepHours(darkMode)
                                  : _buildStepDays(darkMode),
                    ),
                  ),
                ),
              ),

              // ── BOTTOM (stays fixed) ───────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xff26a69a)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Back",
                              style: TextStyle(color: Color(0xff26a69a))),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : (_currentStep < 3 ? _nextStep : _saveData),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff26a69a),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                _currentStep < 3 ? "Next" : "Save & Continue",
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Reusable Option Card ──────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final bool darkMode;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.selected,
    required this.darkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff26a69a)
              : (darkMode ? const Color(0xff1A1E37) : const Color(0xffEFEDE8)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xff26a69a) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected
                  ? Colors.white
                  : (darkMode ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (darkMode ? Colors.white70 : Colors.black87),
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
