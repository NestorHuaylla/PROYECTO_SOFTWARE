import 'package:flutter/material.dart';

import '../../../applied_learning/domain/models/exercise.dart';
import '../../../progress/domain/services/progress_service.dart';

class ExerciseDemoScreen extends StatefulWidget {
  const ExerciseDemoScreen({super.key, required this.progressService});

  final ProgressService progressService;

  @override
  State<ExerciseDemoScreen> createState() => _ExerciseDemoScreenState();
}

class _ExerciseDemoScreenState extends State<ExerciseDemoScreen> {
  static final _exercise = Exercise(
    id: 'demo-ecosystem-001',
    prompt: '¿Qué elemento proporciona energía inicial a la mayoría '
        'de los ecosistemas?',
    options: const [
      ExerciseOption(id: 'sun', text: 'La luz del Sol'),
      ExerciseOption(id: 'soil', text: 'El suelo'),
      ExerciseOption(id: 'water', text: 'El agua'),
    ],
    correctOptionId: 'sun',
    explanation: 'La luz solar es capturada por los productores y sostiene '
        'la mayoría de las cadenas alimentarias.',
    points: 10,
    modality: 'seleccion_multiple',
  );

  String? _selectedOptionId;
  String? _attemptId;
  ExerciseSubmission? _submission;
  Object? _error;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final selection = _selectedOptionId;
    if (selection == null || _isSubmitting || _submission != null) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final attemptId = _attemptId ??= ProgressService.createAttemptId();
      final submission = await widget.progressService.submitAnswer(
        exercise: _exercise,
        selectedOptionId: selection,
        attemptId: attemptId,
      );
      if (!mounted) return;
      setState(() => _submission = submission);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aprendizaje aplicado')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(_exercise.prompt, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final option in _exercise.options)
            RadioListTile<String>(
              value: option.id,
              groupValue: _selectedOptionId,
              title: Text(option.text),
              onChanged: _submission == null && !_isSubmitting
                  ? (value) => setState(() => _selectedOptionId = value)
                  : null,
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _selectedOptionId == null ||
                    _isSubmitting ||
                    _submission != null
                ? null
                : _submit,
            child: Text(_isSubmitting ? 'Evaluando…' : 'Enviar respuesta'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              'No se pudo guardar el intento: $_error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_submission case final submission?) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.attempt.isCorrect
                          ? '¡Respuesta correcta!'
                          : 'Respuesta incorrecta',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(submission.explanation),
                    const SizedBox(height: 8),
                    Text('Puntos obtenidos: ${submission.attempt.pointsEarned}'),
                    Text('Puntos acumulados: ${submission.progress.totalPoints}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
