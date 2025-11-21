import 'package:flutter/material.dart';
import 'package:paper_gen/ProviderData/QuestionData.dart';
import 'package:provider/provider.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final questionData = Provider.of<QuestionData>(context, listen: false);

    return AlertDialog(
      title: const Text('Select Difficulty'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: questionData.difficultyList.map<Widget>((difficulty) {
          return RadioListTile<String>(
            title: Text(difficulty),
            value: difficulty,
            groupValue: questionData.selectedDefaultDifficulty,
            onChanged: (value) {
              if (value != null) {
                int index = questionData.difficultyList.indexOf(value);
                questionData.setSelectedDefaultDifficulty(index);
                Navigator.pop(context);
              }
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// Usage: Call this function where you need to show the dialog
void showDifficultyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const DifficultyDialog(),
  );
}

// Widget version for trailing parameter
class DifficultyDialogButton extends StatelessWidget {
  const DifficultyDialogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDifficultyDialog(context),
      child: Consumer<QuestionData>(
        builder: (context, questionData, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                questionData.selectedDefaultDifficulty,
                style: const TextStyle(
                  color: Color(0xff26a69a),
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xff26a69a),
                size: 16,
              ),
            ],
          );
        },
      ),
    );
  }
}

// Alternative: Simple list dialog without radio buttons
void showSimpleDifficultyDialog(BuildContext context) {
  final questionData = Provider.of<QuestionData>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Difficulty'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: questionData.difficultyList.length,
          itemBuilder: (context, index) {
            final difficulty = questionData.difficultyList[index];
            final isSelected =
                difficulty == questionData.selectedDefaultDifficulty;

            return ListTile(
              title: Text(difficulty),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                questionData.setSelectedDefaultDifficulty(index);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    ),
  );
}
