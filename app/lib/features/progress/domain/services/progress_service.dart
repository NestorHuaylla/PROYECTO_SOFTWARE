import 'dart:async';
import 'dart:math';

import '../../../applied_learning/domain/models/exercise.dart';
import '../../../applied_learning/domain/services/exercise_evaluator.dart';
import '../models/exercise_attempt.dart';
import '../models/student_progress.dart';
import '../repositories/progress_repository.dart';

class ExerciseSubmission {
  const ExerciseSubmission({
    required this.attempt,
    required this.explanation,
    required this.progress,
    required this.wasAlreadyRecorded,
  });

  final ExerciseAttempt attempt;
  final String explanation;
  final StudentProgress progress;
  final bool wasAlreadyRecorded;
}

class ProgressService {
  ProgressService({
    required ProgressRepository repository,
    ExerciseEvaluator evaluator = const ExerciseEvaluator(),
    DateTime Function()? clock,
  }) : _repository = repository,
       _evaluator = evaluator,
       _clock = clock ?? DateTime.now,
       _ready = repository.load();

  final ProgressRepository _repository;
  final ExerciseEvaluator _evaluator;
  final DateTime Function() _clock;
  final Future<StudentProgress> _ready;
  StudentProgress? _progress;
  Future<void> _queue = Future<void>.value();

  Future<StudentProgress> getProgress() async {
    _progress ??= await _ready;
    return _progress!;
  }

  Future<ExerciseSubmission> submitAnswer({
    required Exercise exercise,
    required String selectedOptionId,
    required String attemptId,
  }) {
    final completer = Completer<ExerciseSubmission>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(
          await _submitAnswer(
            exercise: exercise,
            selectedOptionId: selectedOptionId,
            attemptId: attemptId,
          ),
        );
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<ExerciseSubmission> _submitAnswer({
    required Exercise exercise,
    required String selectedOptionId,
    required String attemptId,
  }) async {
    final evaluation = _evaluator.evaluate(
      exercise: exercise,
      selectedOptionId: selectedOptionId,
    );
    if (attemptId.trim().isEmpty) {
      throw ArgumentError.value(attemptId, 'attemptId', 'No puede estar vacío.');
    }

    final current = _progress ??= await _ready;
    final existing = current.attempts.where((attempt) => attempt.id == attemptId);
    if (existing.isNotEmpty) {
      final attempt = existing.single;
      if (attempt.exerciseId != exercise.id ||
          attempt.selectedOptionId != selectedOptionId ||
          attempt.modality != exercise.modality ||
          attempt.isCorrect != evaluation.isCorrect ||
          attempt.pointsEarned != evaluation.pointsEarned) {
        throw StateError('El identificador del intento ya fue usado.');
      }
      return ExerciseSubmission(
        attempt: attempt,
        explanation: exercise.explanation,
        progress: current,
        wasAlreadyRecorded: true,
      );
    }

    final attempt = ExerciseAttempt(
      id: attemptId,
      exerciseId: exercise.id,
      selectedOptionId: selectedOptionId,
      isCorrect: evaluation.isCorrect,
      pointsEarned: evaluation.pointsEarned,
      modality: exercise.modality,
      occurredAt: _clock(),
    );
    final updated = StudentProgress(
      totalPoints: current.totalPoints + attempt.pointsEarned,
      attempts: [...current.attempts, attempt],
    );

    await _repository.save(updated);
    _progress = updated;
    return ExerciseSubmission(
      attempt: attempt,
      explanation: evaluation.explanation,
      progress: updated,
      wasAlreadyRecorded: false,
    );
  }

  static String createAttemptId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final value = hex.join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }
}
