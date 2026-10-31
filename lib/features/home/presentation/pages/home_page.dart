import 'package:flutter/material.dart';
import 'package:corrige_ai/features/assessment/presentation/pages/camera_page.dart';
import 'package:corrige_ai/features/assessment/domain/models/assessment_model.dart';
import 'package:corrige_ai/features/assessment/presentation/pages/preview_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:corrige_ai/features/assessment/data/repositories/gemini_correction_repository_impl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CorrigeAI - Painel do Professor'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cartão de Boas-Vindas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, Professor(a)!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crie novas avaliações ou escaneie os cartões-resposta para correção automática.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botões de Ação Rápida
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'Nova Prova',
                    color: Colors.blue.shade700,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreviewPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: Icons.qr_code_scanner,
                    label: 'Corrigir Prova',
                    color: Colors.green.shade700,
                    onTap: () {
                      const dummyQuestion = QuestionModel(
                        number: 1,
                        type: QuestionType.discursive,
                        statement: 'Explique as principais causas da Revolução Francesa.',
                        expectedAnswer: 'Crise financeira, divisão em três estados e ideias iluministas.',
                        maxScore: 2.0,
                        rubric: [
                          RubricCriterion(
                            description: 'Mencionou a crise econômica e o Terceiro Estado',
                            scoreWeight: 1.0,
                          ),
                          RubricCriterion(
                            description: 'Citou a influência das ideias iluministas',
                            scoreWeight: 1.0,
                          ),
                        ],
                      );

                      final repository = GeminiCorrectionRepositoryImpl(
                        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraPage(
                            question: dummyQuestion,
                            repository: repository,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Título Correções Recentes
            const Text(
              'Correções Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Lista Dinâmica do Hive (Persistência)
            ValueListenableBuilder<Box>(
              valueListenable: Hive.box('corrections').listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Text('Nenhuma correção salva ainda.');
                }

                final keys = box.keys.toList().reversed.toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    // PROTEÇÃO CONTRA DADOS ANTIGOS/CORROMPIDOS
                    final data = Map<String, dynamic>.from(box.get(keys[index]) as Map);
                    final total = (data['totalScore'] as num?)?.toDouble() ?? 0.0;
                    final max = (data['maxScore'] as num?)?.toDouble() ?? 0.0;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(data['question'] ?? 'Questão'),
                        subtitle: Text('Nota: ${total.toStringAsFixed(1)} / ${max.toStringAsFixed(1)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            box.delete(keys[index]);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}