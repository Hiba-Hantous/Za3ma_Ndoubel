import '../models/subject.dart';

/// Calculates the average of a single module from its sub-exams.
/// Returns null if any sub-exam grade is missing.
double? calculateModuleAverage(Subject subject) {
  double totalWeighted = 0;
  double totalCoeff = 0;

  for (final sub in subject.subExams) {
    if (sub.grade == null) return null;
    totalWeighted += sub.grade! * sub.coefficient;
    totalCoeff += sub.coefficient;
  }

  if (totalCoeff == 0) return null;
  return totalWeighted / totalCoeff;
}

/// Calculates the trimester average from all module averages.
/// Returns null if any module average cannot be computed (missing grades).
double? calculateTrimesterAverage(List<Subject> subjects) {
  double totalWeighted = 0;
  double totalCoeff = 0;

  for (final subject in subjects) {
    final avg = calculateModuleAverage(subject);
    if (avg == null) return null;
    totalWeighted += avg * subject.coefficient;
    totalCoeff += subject.coefficient;
  }

  if (totalCoeff == 0) return null;
  return totalWeighted / totalCoeff;
}

/// Calculates the trimester average only from subjects that are fully filled.
/// Skips incomplete subjects instead of returning null.
/// Useful for partial previews while the user is still entering grades.
double? calculatePartialTrimesterAverage(List<Subject> subjects) {
  double totalWeighted = 0;
  double totalCoeff = 0;

  for (final subject in subjects) {
    final avg = calculateModuleAverage(subject);
    if (avg == null) continue; // skip incomplete subjects
    totalWeighted += avg * subject.coefficient;
    totalCoeff += subject.coefficient;
  }

  if (totalCoeff == 0) return null;
  return totalWeighted / totalCoeff;
}

/// Returns a mention (appreciation) based on the Tunisian grading system.
String getMention(double average) {
  if (average >= 18) return 'Très Bien';
  if (average >= 16) return 'Bien';
  if (average >= 14) return 'Assez Bien';
  if (average >= 10) return 'Passable';
  return 'Insuffisant';
}