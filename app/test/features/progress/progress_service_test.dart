import 'package:app/features/applied_learning/domain/models/exercise.dart';
import 'package:app/features/applied_learning/domain/services/exercise_evaluator.dart';
import 'package:app/features/demo/presentation/screens/exercise_demo_screen.dart';
import 'package:app/features/progress/domain/models/student_progress.dart';
import 'package:app/features/progress/domain/repositories/progress_repository.dart';
import 'package:app/features/progress/domain/services/progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 17, 12);

  Exercise buildExercise({
    List<ExerciseOption>? options,
    String correctOptionId = 'correct',
  }) {
    return Exercise(
      id: 'exercise-1',
      prompt: 'Pregunta',
      options:
          options ??
          const [
            ExerciseOption(id: 'correct', text: 'Correcta'),
            ExerciseOption(id: 'wrong', text: 'Incorrecta'),
          ],
      correctOptionId: correctOptionId,
      explanation: 'Esta es la explicación.',
      points: 15,
      modality: 'seleccion_multiple',
    );
  }

  ProgressService createService(MemoryProgressRepository repository) =>
      ProgressService(repository: repository, clock: () => now);

  test('registra una respuesta correcta, puntos y retroalimentación', () async {
    final repository = MemoryProgressRepository();
    final service = createService(repository);

    final result = await service.submitAnswer(
      exercise: buildExercise(),
      selectedOptionId: 'correct',
      attemptId: 'attempt-1',
    );

    expect(result.attempt.isCorrect, isTrue);
    expect(result.attempt.pointsEarned, 15);
    expect(result.attempt.exerciseId, 'exercise-1');
    expect(result.attempt.selectedOptionId, 'correct');
    expect(result.attempt.modality, 'seleccion_multiple');
    expect(result.attempt.occurredAt, now);
    expect(result.explanation, 'Esta es la explicación.');
    expect(result.progress.totalPoints, 15);
    expect(repository.savedProgress?.attempts, hasLength(1));
  });

  test('registra respuesta incorrecta sin sumar puntos', () async {
    final repository = MemoryProgressRepository();
    final result = await createService(repository).submitAnswer(
      exercise: buildExercise(),
      selectedOptionId: 'wrong',
      attemptId: 'attempt-2',
    );

    expect(result.attempt.isCorrect, isFalse);
    expect(result.attempt.pointsEarned, 0);
    expect(result.progress.totalPoints, 0);
    expect(result.explanation, 'Esta es la explicación.');
  });

  test('rechaza selección ajena a las opciones sin registrar intento', () async {
    final repository = MemoryProgressRepository();

    await expectLater(
      createService(repository).submitAnswer(
        exercise: buildExercise(),
        selectedOptionId: 'unknown',
        attemptId: 'attempt-3',
      ),
      throwsArgumentError,
    );

    expect(repository.saveCalls, 0);
    expect((await createService(repository).getProgress()).attempts, isEmpty);
  });

  test('rechaza ejercicio sin opciones o sin respuesta correcta válida', () {
    const evaluator = ExerciseEvaluator();

    expect(
      () => evaluator.evaluate(
        exercise: buildExercise(options: const []),
        selectedOptionId: 'correct',
      ),
      throwsArgumentError,
    );
    expect(
      () => evaluator.evaluate(
        exercise: buildExercise(correctOptionId: 'missing'),
        selectedOptionId: 'correct',
      ),
      throwsArgumentError,
    );
  });

  test('un identificador repetido no duplica el intento ni sus puntos', () async {
    final repository = MemoryProgressRepository();
    final service = createService(repository);
    final exercise = buildExercise();

    final results = await Future.wait([
      service.submitAnswer(
        exercise: exercise,
        selectedOptionId: 'correct',
        attemptId: 'same-attempt',
      ),
      service.submitAnswer(
        exercise: exercise,
        selectedOptionId: 'correct',
        attemptId: 'same-attempt',
      ),
    ]);
    final first = results.first;
    final duplicate = results.last;

    expect(first.wasAlreadyRecorded, isFalse);
    expect(duplicate.wasAlreadyRecorded, isTrue);
    expect(duplicate.progress.totalPoints, 15);
    expect(duplicate.progress.attempts, hasLength(1));
    expect(repository.saveCalls, 1);
  });

  test('un error al guardar no modifica el progreso en memoria', () async {
    final repository = MemoryProgressRepository()..failOnSave = true;
    final service = createService(repository);

    await expectLater(
      service.submitAnswer(
        exercise: buildExercise(),
        selectedOptionId: 'correct',
        attemptId: 'attempt-failure',
      ),
      throwsStateError,
    );

    expect((await service.getProgress()).totalPoints, 0);
    expect((await service.getProgress()).attempts, isEmpty);
  });

  testWidgets(
    'la pantalla muestra el resultado y la explicación',
    (WidgetTester tester) async {
      final service = createService(MemoryProgressRepository());
      await tester.pumpWidget(
        MaterialApp(home: ExerciseDemoScreen(progressService: service)),
      );

      await tester.tap(find.text('La luz del Sol'));
      await tester.pump();
      await tester.tap(find.text('Enviar respuesta'));
      await tester.pumpAndSettle();

      expect(find.text('¡Respuesta correcta!'), findsOneWidget);
      expect(
        find.text(
          'La luz solar es capturada por los productores y sostiene '
          'la mayoría de las cadenas alimentarias.',
        ),
        findsOneWidget,
      );
      expect(find.text('Puntos obtenidos: 10'), findsOneWidget);
    },
  );
}

class MemoryProgressRepository implements ProgressRepository {
  StudentProgress savedProgress = StudentProgress.empty();
  int saveCalls = 0;
  bool failOnSave = false;

  @override
  Future<StudentProgress> load() async => savedProgress;

  @override
  Future<void> save(StudentProgress progress) async {
    saveCalls++;
    if (failOnSave) throw StateError('Storage unavailable');
    savedProgress = progress;
  }
}
