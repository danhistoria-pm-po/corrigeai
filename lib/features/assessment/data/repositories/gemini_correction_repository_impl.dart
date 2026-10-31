import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:corrige_ai/features/assessment/domain/models/correction_result_model.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/assessment_model.dart';
import '../../domain/repositories/correction_repository.dart';

class GeminiCorrectionRepositoryImpl implements CorrectionRepository {
  final String apiKey;
  final String model;

    GeminiCorrectionRepositoryImpl({
    required this.apiKey,
    this.model = 'gemini-3.8-flash', // CORRIGIDO AQUI
  });

  @override
  Future<CorrectionResultModel> evaluateAnswer({
    required Uint8List imageBytes,
    required String mimeType, // REMOVIDO O = 'image/jpeg'
    required QuestionModel question,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('A chave GEMINI_API_KEY não foi encontrada ou está vazia no ficheiro .env');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    
    final base64Image = base64Encode(imageBytes);

    final rubricsFormatted = question.rubric != null && question.rubric!.isNotEmpty
        ? question.rubric!.map((r) => '- ${r.description} (Valor: ${r.scoreWeight} pts)').join('\n')
        : 'Sem rubricas específicas. Avalie com base na resposta esperada.';

    final promptText = '''
Você é um corretor pedagógico especialista.
Sua tarefa é analisar a resposta manuscrita do aluno na imagem enviada e avaliá-la rigorosamente com base nas rubricas fornecidas.

ENUNCIADO DA QUESTÃO:
"${question.statement ?? 'Sem enunciado'}"

GABARITO OFICIAL / RESPOSTA ESPERADA:
"${question.expectedAnswer ?? 'Sem gabarito cadastrado'}"

CRITÉRIOS DE AVALIAÇÃO (RUBRICAS):
$rubricsFormatted

Responda rigorosamente no schema JSON configurado.
''';

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": promptText},
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Image
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "temperature": 0.2,
        "responseSchema": {
          "type": "OBJECT",
          "properties": {
            "transcription": {"type": "STRING"},
            "totalScore": {"type": "NUMBER"},
            "feedback": {"type": "STRING"},
            "rubricEvaluations": {
              "type": "ARRAY",
              "items": {
                "type": "OBJECT",
                "properties": {
                  "description": {"type": "STRING"},
                  "assignedScore": {"type": "NUMBER"},
                  "maxScore": {"type": "NUMBER"},
                  "justification": {"type": "STRING"}
                },
                "required": ["description", "assignedScore", "maxScore", "justification"]
              }
            }
          },
          "required": ["transcription", "totalScore", "feedback", "rubricEvaluations"]
        }
      }
    };

    const retryableCodes = {429, 500, 502, 503, 504};
    const maxAttempts = 4;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
         final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 30)); 

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final candidates = responseData['candidates'] as List?;
          if (candidates == null || candidates.isEmpty) {
            throw Exception('Resposta bloqueada ou vazia: ${responseData['promptFeedback']}');
          }
          final parts = candidates[0]['content']['parts'] as List;
          final rawText = parts.map((p) => p['text'] ?? '').join();

          return CorrectionResultModel.fromJson(jsonDecode(rawText));
        }

        if (retryableCodes.contains(response.statusCode) && attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: 2 * attempt));
          continue;
        }

        throw Exception('Erro na comunicação com o Gemini: ${response.statusCode} - ${response.body}');
      } on TimeoutException {
        if (attempt == maxAttempts) {
          throw Exception('O Gemini demorou demais para responder.');
        }
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    throw Exception('Não foi possível obter resposta do Gemini após $maxAttempts tentativas.');
  }
}