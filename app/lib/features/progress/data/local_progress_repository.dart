import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/student_progress.dart';
import '../domain/repositories/progress_repository.dart';

class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _storageKey = 'student_progress_v1';
  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _store async =>
      _preferences ?? await SharedPreferences.getInstance();

  @override
  Future<StudentProgress> load() async {
    final json = (await _store).getString(_storageKey);
    if (json == null) return StudentProgress.empty();
    try {
      return StudentProgress.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('No se pudo leer el progreso guardado: $error');
    }
  }

  @override
  Future<void> save(StudentProgress progress) async {
    final saved = await (await _store).setString(
      _storageKey,
      jsonEncode(progress.toJson()),
    );
    if (!saved) {
      throw StateError('No se pudo persistir el progreso del estudiante.');
    }
  }
}
