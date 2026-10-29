import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/models/assessment_model.dart';

class PdfService {
  static Future<Uint8List> generateAnswerSheetPdf({
    required AssessmentModel assessment,
    required String studentName,
    required String studentId,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'CorrigeAI - Folha de Resposta',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: assessment.id,
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Prova: ${assessment.title}'),
              pw.Text('Disciplina: ${assessment.subject}'),
              pw.Text('Turma: ${assessment.schoolClass}'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Aluno: ${studentName.isEmpty ? '______________________________________' : studentName}',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Espaço para Resposta Discursiva:',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 400,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    15,
                    (index) => pw.Divider(color: PdfColors.grey300),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}