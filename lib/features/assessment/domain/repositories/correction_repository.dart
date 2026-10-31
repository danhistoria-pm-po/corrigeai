import 'dart:typed_data';
import '../models/assessment_model.dart';
import '../models/correction_result_model.dart';

abstract class CorrectionRepository {
  Future<CorrectionResultModel> evaluateAnswer({
    required Uint8List imageBytes,
    required String mimeType,
    required QuestionModel question,
  });
}