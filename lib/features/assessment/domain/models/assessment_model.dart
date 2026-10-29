import 'package:equatable/equatable.dart';

/// Define o tipo de questão da avaliação
enum QuestionType { objective, discursive }

/// Modelo para a Rubrica de Correção da Questão Discursiva
class RubricCriterion extends Equatable {
  final String description; // Ex: "Mencionou o conceito correto de latitude"
  final double scoreWeight;  // Ex: 0.5 (Pontuação atribuída a este critério)

  const RubricCriterion({
    required this.description,
    required this.scoreWeight,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'scoreWeight': scoreWeight,
    };
  }

  factory RubricCriterion.fromMap(Map<String, dynamic> map) {
    return RubricCriterion(
      description: map['description'] ?? '',
      scoreWeight: (map['scoreWeight'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [description, scoreWeight];
}

/// Modelo genérico para Questões
class QuestionModel extends Equatable {
  final int number; // Número da questão (1 a 20 para objetivas, 1 a 5 para discursivas)
  final QuestionType type;
  final String? statement; // Enunciado (opcional no cadastro rápido)
  final String? correctOption; // Para objetivas: 'A', 'B', 'C', 'D' ou 'E'
  final String? expectedAnswer; // Para discursivas: Resposta esperada / Gabarito oficial
  final double maxScore; // Pontuação máxima da questão
  final List<RubricCriterion>? rubric; // Critérios para a IA (Apenas discursivas)

  const QuestionModel({
    required this.number,
    required this.type,
    this.statement,
    this.correctOption,
    this.expectedAnswer,
    required this.maxScore,
    this.rubric,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'type': type.name,
      'statement': statement,
      'correctOption': correctOption,
      'expectedAnswer': expectedAnswer,
      'maxScore': maxScore,
      'rubric': rubric?.map((r) => r.toMap()).toList(),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      number: map['number'] ?? 0,
      type: QuestionType.values.byName(map['type'] ?? 'objective'),
      statement: map['statement'],
      correctOption: map['correctOption'],
      expectedAnswer: map['expectedAnswer'],
      maxScore: (map['maxScore'] as num).toDouble(),
      rubric: map['rubric'] != null
          ? List<RubricCriterion>.from(
              map['rubric'].map((x) => RubricCriterion.fromMap(x)),
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [
        number,
        type,
        statement,
        correctOption,
        expectedAnswer,
        maxScore,
        rubric,
      ];
}

/// Modelo Principal da Prova / Avaliação
class AssessmentModel extends Equatable {
  final String id;
  final String teacherId;
  final String title;
  final String subject; // Ex: "História", "Geografia"
  final String schoolClass; // Ex: "9º Ano A"
  final DateTime createdAt;
  final List<QuestionModel> objectiveQuestions; // Máximo 20
  final List<QuestionModel> discursiveQuestions; // Máximo 5

  const AssessmentModel({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.subject,
    required this.schoolClass,
    required this.createdAt,
    required this.objectiveQuestions,
    required this.discursiveQuestions,
  });

  bool get hasObjective => objectiveQuestions.isNotEmpty;
  bool get hasDiscursive => discursiveQuestions.isNotEmpty;
  int get totalObjectiveCount => objectiveQuestions.length;
  int get totalDiscursiveCount => discursiveQuestions.length;

  double get totalMaxScore {
    final objScore = objectiveQuestions.fold(0.0, (sum, q) => sum + q.maxScore);
    final discScore = discursiveQuestions.fold(0.0, (sum, q) => sum + q.maxScore);
    return objScore + discScore;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'title': title,
      'subject': subject,
      'schoolClass': schoolClass,
      'createdAt': createdAt.toIso8601String(),
      'objectiveQuestions': objectiveQuestions.map((q) => q.toMap()).toList(),
      'discursiveQuestions': discursiveQuestions.map((q) => q.toMap()).toList(),
    };
  }

  factory AssessmentModel.fromMap(Map<String, dynamic> map) {
    return AssessmentModel(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      schoolClass: map['schoolClass'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      objectiveQuestions: List<QuestionModel>.from(
        (map['objectiveQuestions'] ?? []).map((x) => QuestionModel.fromMap(x)),
      ),
      discursiveQuestions: List<QuestionModel>.from(
        (map['discursiveQuestions'] ?? []).map((x) => QuestionModel.fromMap(x)),
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        teacherId,
        title,
        subject,
        schoolClass,
        createdAt,
        objectiveQuestions,
        discursiveQuestions,
      ];
}