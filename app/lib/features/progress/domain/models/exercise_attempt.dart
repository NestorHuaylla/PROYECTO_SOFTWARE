class ExerciseAttempt {
  const ExerciseAttempt({
    required this.id,
    required this.exerciseId,
    required this.selectedOptionId,
    required this.isCorrect,
    required this.pointsEarned,
    required this.modality,
    required this.occurredAt,
  });

  final String id;
  final String exerciseId;
  final String selectedOptionId;
  final bool isCorrect;
  final int pointsEarned;
  final String modality;
  final DateTime occurredAt;

  Map<String, Object> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'selectedOptionId': selectedOptionId,
    'isCorrect': isCorrect,
    'pointsEarned': pointsEarned,
    'modality': modality,
    'occurredAt': occurredAt.toIso8601String(),
  };

  factory ExerciseAttempt.fromJson(Map<String, dynamic> json) {
    return ExerciseAttempt(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      selectedOptionId: json['selectedOptionId'] as String,
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: json['pointsEarned'] as int,
      modality: json['modality'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );
  }
}
