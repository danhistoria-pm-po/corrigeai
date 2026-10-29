import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../domain/models/assessment_model.dart';

class GeminiService {
  final String apiKey;
  final String model;

  GeminiService({
    required this.apiKey,
    this.model = 'gemini-3.8-flash', // Modelo atualizado e configurável
  });

  /// Envia a foto da resposta manuscrita do aluno + critérios da rubrica para o Gemini
  Future<Map<String, dynamic>> evaluateAnswer({
    required Uint8List imageBytes,
    required QuestionModel question,
  }) async {
    // URL dinâmica baseada no modelo ativo
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    
    // Converte a imagem para Base64
    final base64Image = base64Encode(imageBytes);

    // Formata os critérios da rubrica cadastrados no modelo
    final rubricsFormatted = question.rubric != null && question.rubric!.isNotEmpty
        ? question.rubric!.map((r) => '- ${r.description} (Valor: ${r.scoreWeight} pts)').join('\n')
        : 'Sem rubricas específicas. Avalie com base na resposta esperada.';

    // Monta o prompt pedagógico instruindo o Gemini a retornar JSON estruturado
    final promptText = '''
Você é um corretor pedagógico especialista.
Sua tarefa é analisar a resposta manuscrita do aluno na imagem enviada e avaliá-la rigorosamente com base nas rubricas fornecidas.

ENUNCIADO DA QUESTÃO:
"${question.statement ?? 'Sem enunciado'}"

GABARITO OFICIAL / RESPOSTA ESPERADA:
"${question.expectedAnswer ?? 'Sem gabarito cadastrado'}"

CRITÉRIOS DE AVALIAÇÃO (RUBRICAS):
$rubricsFormatted

INSTRUÇÕES DE SAÍDA:
Retorne EXCLUSIVAMENTE um objeto JSON válido no seguinte formato sem marcações de código markdown extras:
{
  "transcription": "Texto exato transcrito da caligrafia do aluno",
  "totalScore": 0.0,
  "feedback": "Justificativa pedagógica geral para o aluno",
  "rubricEvaluations": [
    {
      "description": "Descrição do critério de avaliação",
      "assignedScore": 0.0,
      "maxScore": 0.0,
      "justification": "Por que o aluno recebeu essa nota neste critério específico"
    }
  ]
}
''';

 // Corpo da requisição usando o padrão camelCase estrito da Google
    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": promptText},
            {
              "inlineData": { // CORRIGIDO: de inline_data para inlineData
                "mimeType": "image/jpeg", // CORRIGIDO: de mime_type para mimeType
                "data": base64Image
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "temperature": 0.2
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final rawText = responseData['candidates'][0]['content']['parts'][0]['text'];

        // Converte o texto JSON retornado pela IA para Map do Dart
        return jsonDecode(rawText) as Map<String, dynamic>;
      } else {
        // CORRIGIDO: String de erro unificada numa única linha para evitar falha de compilação
        throw Exception('Erro na comunicação com o Gemini: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao avaliar a prova com a IA: $e');
    }
  }
}