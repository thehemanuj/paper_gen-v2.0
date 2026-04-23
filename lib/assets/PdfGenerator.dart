import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:paper_gen/assets/HelperClasses.dart';

class PdfGenerator {
  static Future<String> generatePaperPdf(GeneratedPaper paper) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('PAPER GEN - EXAM PORTAL',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Generated Practice Paper',
                      style: const pw.TextStyle(fontSize: 16)),
                  pw.Divider(),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                pw.Text('Total Questions: ${paper.totalQuestions}'),
              ],
            ),
            pw.SizedBox(height: 20),
            ...paper.subjects.expand((subject) {
              return [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Text(
                    'Subject: ${subject.subject} (${subject.difficulty})',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                ...subject.questions.asMap().entries.map((entry) {
                  int qIndex = entry.key;
                  var q = entry.value;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 15),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Q${qIndex + 1}: ${q.question}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        ...q.options!.asMap().entries.map((optEntry) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 20, bottom: 2),
                            child: pw.Text(
                                '${String.fromCharCode(65 + optEntry.key)}) ${optEntry.value}'),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ];
            }).toList(),
            pw.NewPage(),
            pw.Header(level: 1, text: 'Answer Key'),
            pw.SizedBox(height: 10),
            ...paper.subjects.expand((subject) {
              return subject.questions.asMap().entries.map((entry) {
                return pw.Text('Q${entry.key + 1}: ${entry.value.answer}');
              }).toList();
            }).toList(),
            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('--- Mock OMR Sheet Section ---',
                      style: pw.TextStyle(color: PdfColors.grey)),
                  pw.SizedBox(height: 10),
                  pw.Text('Use this area to practice your bubbling!'),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/Generated_Paper_${paper.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
