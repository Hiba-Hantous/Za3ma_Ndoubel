import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';

class StorageService {
  static String _key(int trimester, String subjectName, String subExamName) =>
      'grade_t${trimester}_${subjectName}_${subExamName}';

  static Future<void> saveGrade(
    int trimester,
    String subjectName,
    String subExamName,
    double? grade,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(trimester, subjectName, subExamName);
    if (grade == null) {
      await prefs.remove(key);
    } else {
      await prefs.setDouble(key, grade);
    }
  }

  static Future<double?> loadGrade(
    int trimester,
    String subjectName,
    String subExamName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key(trimester, subjectName, subExamName));
  }

  static Future<void> saveAllGrades(
    int trimester,
    List<Subject> subjects,
  ) async {
    for (final subject in subjects) {
      for (final sub in subject.subExams) {
        await saveGrade(trimester, subject.name, sub.name, sub.grade);
      }
    }
  }

  static Future<List<Subject>> loadAllGrades(
    int trimester,
    List<Subject> subjects,
  ) async {
    final result = <Subject>[];
    for (final subject in subjects) {
      final updatedSubs = <SubExam>[];
      for (final sub in subject.subExams) {
        final grade = await loadGrade(trimester, subject.name, sub.name);
        updatedSubs.add(grade != null ? sub.copyWith(grade: grade) : sub);
      }
      result.add(subject.copyWith(subExams: updatedSubs));
    }
    return result;
  }

  static Future<void> clearTrimester(int trimester) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'grade_t${trimester}_';
    final matching = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final key in matching) {
      await prefs.remove(key);
    }
  }
}
