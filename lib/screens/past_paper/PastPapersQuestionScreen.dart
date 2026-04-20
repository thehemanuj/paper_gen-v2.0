import 'package:flutter/material.dart';

class PastPapersQuestionScreen extends StatelessWidget {
  const PastPapersQuestionScreen(this.questions, this.isDarkMode, {super.key});
  final List questions;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        isDarkMode ? const Color(0xff0A0E27) : const Color(0xffFDFBF7);
    final Color cardColor =
        isDarkMode ? const Color(0xff1A1F3C) : const Color(0xffFFFFFF);
    final Color textColor =
        isDarkMode ? const Color(0xffE8EAF6) : const Color(0xff1A1A2E);
    final Color subTextColor =
        isDarkMode ? const Color(0xff9FA8DA) : const Color(0xff5C5C7B);
    final Color accentColor = const Color(0xff6C63FF);
    final Color optionBgColor =
        isDarkMode ? const Color(0xff252A48) : const Color(0xffF3F0FF);
    final Color answerBgColor =
        isDarkMode ? const Color(0xff0D3B2E) : const Color(0xffE8F5E9);
    final Color explanationBgColor =
        isDarkMode ? const Color(0xff1A2744) : const Color(0xffE8EEF9);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('images/papergen_border_up.png'),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back, color: Color(0xff26a69a)),
                  SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(color: Color(0xff26a69a), fontSize: 25.0),
                  ),
                ],
              ),
            ),
          ),
          // ── Question list ────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final List options = q.options ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black38
                            : Colors.black.withOpacity(0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Question header ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                q.question ?? '',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Options ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Column(
                          children: List.generate(options.length, (i) {
                            final label =
                                String.fromCharCode(65 + i); // A, B, C, D
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: optionBgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '$label.',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      options[i].toString(),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 14),
                      Divider(
                          color: subTextColor.withOpacity(0.2),
                          thickness: 1,
                          indent: 16,
                          endIndent: 16),

                      // ── Explanation ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: explanationBgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: accentColor.withOpacity(0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_outline,
                                      color: accentColor, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Explanation',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                q.explanation ?? '',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13.5,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Answer ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: answerBgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.green.withOpacity(0.35)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Answer: ',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  q.answer ?? '',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
