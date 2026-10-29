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

    return CorrectionResultModel(
      transcription: json['transcription'] ?? '',
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      feedback: json['feedback'] ?? '',
      rubricEvaluations: rubricsList,
    );
  }

  /// Recalcula a nota total com base nas notas individuais ajustadas nas rubricas
  void recalculateTotalScore() {
    totalScore = rubricEvaluations.fold(0.0, (sum, item) => sum + item.assignedScore);
  }
}