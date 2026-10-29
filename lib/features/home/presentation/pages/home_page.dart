import 'package:flutter/material.dart';
import 'package:corrige_ai/features/assessment/presentation/pages/camera_page.dart';
import 'package:corrige_ai/features/assessment/domain/models/assessment_model.dart';
import 'package:corrige_ai/features/assessment/presentation/pages/preview_page.dart';

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
                // Cria uma questão de teste no formato exato do seu assessment_model.dart
                const dummyQuestion = QuestionModel(
                  number: 1,
                  type: QuestionType.discursive,
                  statement: 'Explique as principais causas da Revolução Francesa.',
                  expectedAnswer: 'Crise financeira, divisão em três estados e ideias iluministas.',
                  maxScore: 2.0,
                  rubric: const [
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraPage(question: dummyQuestion),
                  ),
                );
              },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Título Minhas Provas
            const Text(
              'Minhas Avaliações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Lista Exemplo de Provas
            _buildAssessmentCard(
              title: 'Avaliação Bimestral de História',
              subject: 'História | 9º Ano A',
              questionsInfo: '10 Objetivas + 3 Discursivas',
              date: '16/10/2026',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreviewPage(),
                  ),
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

  Widget _buildAssessmentCard({
    required String title,
    required String subject,
    required String questionsInfo,
    required String date,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.assignment, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$subject\n$questionsInfo • $date'),
        trailing: const Icon(Icons.print_outlined, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }
}