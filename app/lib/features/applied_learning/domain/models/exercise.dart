class ExerciseOption {
  const ExerciseOption({required this.id, required this.text});

  final String id;
  final String text;
}

class Exercise {
  Exercise({
    required this.id,
    required this.prompt,
    required List<ExerciseOption> options,
    required this.correctOptionId,
    required this.explanation,
    required this.points,
    required this.modality,
  }) : options = List.unmodifiable(options);

  final String id;
  final String prompt;
  final List<ExerciseOption> options;
  final String correctOptionId;
  final String explanation;
  final int points;
  final String modality;
}
