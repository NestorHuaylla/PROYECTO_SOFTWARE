import '../models/exercise.dart';

class ExerciseEvaluation {
  const ExerciseEvaluation({
    required this.isCorrect,
    required this.explanation,
    required this.pointsEarned,
  });

  final bool isCorrect;
  final String explanation;
  final int pointsEarned;
}

class ExerciseEvaluator {
  const ExerciseEvaluator();

  ExerciseEvaluation evaluate({
    required Exercise exercise,
    required String selectedOptionId,
  }) {
    if (exercise.id.trim().isEmpty) {
      throw ArgumentError.value(exercise.id, 'exercise.id', 'No puede estar vacío.');
    }
    if (exercise.options.isEmpty) {
      throw ArgumentError.value(
        exercise.options,
        'exercise.options',
        'El ejercicio debe tener opciones.',
      );
    }
    if (exercise.points < 0) {
      throw ArgumentError.value(
        exercise.points,
        'exercise.points',
        'No puede ser negativo.',
      );
    }

    final optionIds = exercise.options.map((option) => option.id).toSet();
    if (optionIds.length != exercise.options.length ||
        optionIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError.value(
        exercise.options,
        'exercise.options',
        'Las opciones deben tener identificadores únicos y válidos.',
      );
    }
    if (!optionIds.contains(exercise.correctOptionId)) {
      throw ArgumentError.value(
        exercise.correctOptionId,
        'exercise.correctOptionId',
        'La respuesta correcta debe existir entre las opciones.',
      );
    }
    if (!optionIds.contains(selectedOptionId)) {
      throw ArgumentError.value(
        selectedOptionId,
        'selectedOptionId',
        'La selección debe corresponder a una opción existente.',
      );
    }

    final isCorrect = selectedOptionId == exercise.correctOptionId;
    return ExerciseEvaluation(
      isCorrect: isCorrect,
      explanation: exercise.explanation,
      pointsEarned: isCorrect ? exercise.points : 0,
    );
  }
}
