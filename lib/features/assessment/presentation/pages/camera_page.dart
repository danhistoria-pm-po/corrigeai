import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/models/assessment_model.dart';
import '../../data/services/gemini_service.dart';
import '../../domain/models/correction_result_model.dart';
import 'review_page.dart';

class CameraPage extends StatefulWidget {
  final QuestionModel question;

  const CameraPage({super.key, required this.question});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isAnalyzing = false;

  // Simula a captura de imagem para ambiente Web/Desktop/Emulador com um JPEG válido estruturalmente
  Future<void> _captureAndAnalyze() async {
    setState(() => _isAnalyzing = true);

    try {
      // Bytes reais de um JPEG mínimo válido para evitar erro de decodificação na API
      final dummyBytes = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
        0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
        0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
        0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
        0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
        0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
        0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x0A,
        0x00, 0x0A, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
        0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F,
        0x00, 0x37, 0x01, 0x3F, 0xFF, 0xD9
      ]);

      const apiKey = 'Chave';
      final geminiService = GeminiService(apiKey: apiKey);

      final result = await geminiService.evaluateAnswer(
        imageBytes: dummyBytes,
        question: widget.question,
      );

      if (mounted) {
        setState(() => _isAnalyzing = false);
        
        // Converte o JSON do Gemini no nosso modelo de resultado
        final correctionResult = CorrectionResultModel.fromJson(result);
        
        // Navega para a tela de revisão
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              question: widget.question,
              correctionResult: correctionResult,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na análise: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturar Prova - Gemini 1.5 Flash'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isAnalyzing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Analisando caligrafia e critérios com a IA...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questão: ${widget.question.statement ?? 'Sem enunciado'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Pontuação Máxima: ${widget.question.maxScore} pts'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Posicione a resposta do aluno no quadro'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _captureAndAnalyze,
                    icon: const Icon(Icons.camera),
                    label: const Text('Capturar e Avaliar com IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}