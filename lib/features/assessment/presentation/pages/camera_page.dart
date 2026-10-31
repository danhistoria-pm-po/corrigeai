import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/assessment_model.dart';
import '../../domain/repositories/correction_repository.dart';
import 'review_page.dart';

class CameraPage extends StatefulWidget {
  final QuestionModel question;
  final CorrectionRepository repository;

  const CameraPage({
    super.key,
    required this.question,
    required this.repository,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isAnalyzing = false;
  final _picker = ImagePicker();

  Future<void> _captureAndAnalyze(ImageSource source) async {
      final XFile? photo = await _picker.pickImage(
      source: source,
      maxWidth: 800, // Reduzido de 1600 para 800
      imageQuality: 60, // Reduzido de 85 para 60
    );

    if (photo == null) return;

    final bytes = await photo.readAsBytes();
    setState(() => _isAnalyzing = true);

    try {
      final result = await widget.repository.evaluateAnswer(
        imageBytes: bytes,
        mimeType: photo.mimeType ?? 'image/jpeg',
        question: widget.question,
      );

      if (mounted) {
        setState(() => _isAnalyzing = false);
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              question: widget.question,
              correctionResult: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('503') || e.toString().contains('429')
                  ? 'O serviço de IA está sobrecarregado. Tentamos algumas vezes, mas continua instável. Tente novamente em instantes.'
                  : 'Erro na análise: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturar Prova - IA'),
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
                  OutlinedButton.icon(
                    onPressed: () => _captureAndAnalyze(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Escolher da Galeria / Arquivo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _captureAndAnalyze(ImageSource.camera),
                    icon: const Icon(Icons.camera),
                    label: const Text('Tirar Foto (Câmera)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}