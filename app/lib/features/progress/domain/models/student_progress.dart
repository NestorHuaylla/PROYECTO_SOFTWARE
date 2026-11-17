import 'exercise_attempt.dart';

class StudentProgress {
  StudentProgress({
    required this.totalPoints,
    required List<ExerciseAttempt> attempts,
  }) : attempts = List.unmodifiable(attempts);

  factory StudentProgress.empty() =>
      StudentProgress(totalPoints: 0, attempts: const []);

  final int totalPoints;
  final List<ExerciseAttempt> attempts;

  Map<String, Object> toJson() => {
    'totalPoints': totalPoints,
    'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
  };

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    final totalPoints = json['totalPoints'] as int;
    final rawAttempts = json['attempts'] as List<dynamic>;
    final attempts = rawAttempts
        .map(
          (item) => ExerciseAttempt.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    if (totalPoints < 0 ||
        attempts.any((attempt) => attempt.pointsEarned < 0) ||
        attempts.map((attempt) => attempt.id).toSet().length !=
            attempts.length ||
        totalPoints !=
            attempts.fold<int>(0, (sum, attempt) => sum + attempt.pointsEarned)) {
      throw const FormatException('El progreso guardado no es válido.');
    }

    return StudentProgress(totalPoints: totalPoints, attempts: attempts);
  }
}
