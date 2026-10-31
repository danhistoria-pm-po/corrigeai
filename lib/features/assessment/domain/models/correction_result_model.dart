class RubricEvaluation {
  final String description;
  double assignedScore;
  final double maxScore;
  String justification;

  RubricEvaluation({
    required this.description,
    required this.assignedScore,
    required this.maxScore,
    required this.justification,
  });

  factory RubricEvaluation.fromJson(Map<String, dynamic> json) {
    return RubricEvaluation(
      description: json['description'] ?? '',
      assignedScore: (json['assignedScore'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 0.0,
      justification: json['justification'] ?? '',
    );
  }

  // ADICIONADO: Necessário para o Hive conseguir salvar a lista de rubricas
  Map<String, dynamic> toJson() => {
        'description': description,
        'assignedScore': assignedScore,
        'maxScore': maxScore,
        'justification': justification,
      };
}

class CorrectionResultModel {
  String transcription;
  double totalScore;
  String feedback;
  List<RubricEvaluation> rubricEvaluations;

  CorrectionResultModel({
    required this.transcription,
    required this.totalScore,
    required this.feedback,
    required this.rubricEvaluations,
  });

  factory CorrectionResultModel.fromJson(Map<String, dynamic> json) {
    var rubricsList = (json['rubricEvaluations'] as List<dynamic>?)
            ?.map((r) => RubricEvaluation.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    for (final r in rubricsList) {
      r.assignedScore = _snap(r.assignedScore.clamp(0.0, r.maxScore).toDouble(), r.maxScore);
    }

    return CorrectionResultModel(
      transcription: json['transcription'] ?? '',
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      feedback: json['feedback'] ?? '',
      rubricEvaluations: rubricsList,
    );
  }

  // ADICIONADO: Necessário para o Hive conseguir salvar o objeto inteiro
  Map<String, dynamic> toJson() => {
        'transcription': transcription,
        'totalScore': totalScore,
        'feedback': feedback,
        'rubricEvaluations': rubricEvaluations.map((r) => r.toJson()).toList(),
      };

  static double _snap(double v, double max) {
    if (max <= 0) return 0.0;
    final steps = [0.0, max * 0.25, max * 0.50, max * 0.75, max];
    return steps.reduce((a, b) => (v - a).abs() < (v - b).abs() ? a : b);
  }

  /// Recalcula a nota total com base nas notas individuais ajustadas nas rubricas
  void recalculateTotalScore() {
    totalScore = rubricEvaluations.fold(0.0, (sum, item) => sum + item.assignedScore);
  }
}