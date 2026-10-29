import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../data/services/pdf_service.dart';
import '../../domain/models/assessment_model.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key});

  /// Prova de Exemplo para Testar a Visualização do PDF
  AssessmentModel _getDummyAssessment() {
    return AssessmentModel(
      id: 'PRV-2026-001',
      teacherId: 'PROF-01',
      title: 'Avaliação Bimestral de História',
      subject: 'História',
      schoolClass: '9º Ano A',
      createdAt: DateTime.now(),
      objectiveQuestions: List.generate(
        10,
        (index) => QuestionModel(
          number: index + 1,
          type: QuestionType.objective,
          correctOption: 'A',
          maxScore: 0.5,
        ),
      ),
      discursiveQuestions: List.generate(
        3,
        (index) => QuestionModel(
          number: index + 1,
          type: QuestionType.discursive,
          expectedAnswer: 'Resposta modelo...',
          maxScore: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dummyAssessment = _getDummyAssessment();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartão-Resposta (Preview)'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateAnswerSheetPdf(
          assessment: dummyAssessment,
          studentName: '', // Em branco para o aluno preencher
          studentId: 'ALU-001',
        ),
      ),
    );
  }
}