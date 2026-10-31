import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // IMPORT ADICIONADO
import '../../domain/models/correction_result_model.dart';
import '../../domain/models/assessment_model.dart';

class ReviewPage extends StatefulWidget {
  final QuestionModel question;
  final CorrectionResultModel correctionResult;

  const ReviewPage({
    super.key,
    required this.question,
    required this.correctionResult,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late CorrectionResultModel _result;
  late TextEditingController _transcriptionController;
  late TextEditingController _feedbackController;

  // Função da Régua Proporcional Dinâmica
  List<double> _calculateQuartiles(double maxValue) {
    return [
      0.0,
      maxValue * 0.25,
      maxValue * 0.50,
      maxValue * 0.75,
      maxValue * 1.00,
    ];
  }

  @override
  void initState() {
    super.initState();
    _result = widget.correctionResult;
    _transcriptionController =
        TextEditingController(text: _result.transcription);
    _feedbackController = TextEditingController(text: _result.feedback);
  }

  @override
  void dispose() {
    _transcriptionController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _updateScore(RubricEvaluation evaluation, double newScore) {
    setState(() {
      evaluation.assignedScore = newScore;
      _result.recalculateTotalScore();
    });
  }

  void _saveAndApprove() {
    _result.transcription = _transcriptionController.text;
    _result.feedback = _feedbackController.text;

    // SALVANDO NO HIVE (Persistência E2E)
    final box = Hive.box('corrections');
    box.add({
      'timestamp': DateTime.now().toIso8601String(),
      'question': widget.question.statement ?? 'Sem enunciado',
      'totalScore': _result.totalScore,
      'maxScore': widget.question.maxScore,
      'resultJson': _result.toJson(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Correção aprovada e salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, _result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisão da Correção (IA)'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placar da Nota Final
            Card(
              color: Colors.blue.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nota Atribuída:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_result.totalScore.toStringAsFixed(1)} / ${widget.question.maxScore.toStringAsFixed(1)} pts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Enunciado da Questão
            const Text(
              'Enunciado:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              widget.question.statement ?? 'Sem enunciado',
              style: TextStyle(color: Colors.grey.shade800),
            ),
            const SizedBox(height: 16),

            // Transcrição Manuscrita
            const Text(
              'Transcrição da Resposta do Aluno:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _transcriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Ajuste a transcrição se a IA errou alguma palavra...',
              ),
            ),
            const SizedBox(height: 20),

            // Avaliação por Rubricas
            const Text(
              'Critérios da Rubrica (Ajuste Manual):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._result.rubricEvaluations.map((eval) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eval.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Justificativa da IA: ${eval.justification}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pontuação (Régua Proporcional):',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _calculateQuartiles(eval.maxScore).map((scoreOption) {
                              final isSelected =
                                  (eval.assignedScore - scoreOption).abs() < 0.001;

                              return ChoiceChip(
                                label: Text(scoreOption.toStringAsFixed(2)),
                                selected: isSelected,
                                selectedColor: Colors.blue.shade200,
                                backgroundColor: Colors.grey.shade100,
                                onSelected: (bool selected) {
                                  if (selected) {
                                    _updateScore(eval, scoreOption);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Selecionado: ${eval.assignedScore.toStringAsFixed(2)} / ${eval.maxScore} pts',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Feedback Geral
            const Text(
              'Feedback para o Aluno:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edite ou adicione considerações para o aluno...',
              ),
            ),
            const SizedBox(height: 24),

            // Botão de Aprovação
            ElevatedButton.icon(
              onPressed: _saveAndApprove,
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Aprovar e Salvar Correção',
                style: TextStyle(fontSize: 16),
              ),
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