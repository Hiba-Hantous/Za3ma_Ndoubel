class SubExam {
  final String name;
  final String nameKey;
  final double coefficient;
  double? grade;

  SubExam({
    required this.name,
    required this.nameKey,
    required this.coefficient,
    this.grade,
  });

  SubExam copyWith({double? grade}) {
    return SubExam(
      name: name,
      nameKey: nameKey,
      coefficient: coefficient,
      grade: grade ?? this.grade,
    );
  }
}

class Subject {
  final String name;
  final String nameKey;
  final double coefficient;
  final List<SubExam> subExams;

  Subject({
    required this.name,
    required this.nameKey,
    required this.coefficient,
    required this.subExams,
  });

  double? get moduleAverage {
    double totalWeighted = 0;
    double totalCoeff = 0;
    for (final sub in subExams) {
      if (sub.grade == null) return null;
      totalWeighted += sub.grade! * sub.coefficient;
      totalCoeff += sub.coefficient;
    }
    if (totalCoeff == 0) return null;
    return totalWeighted / totalCoeff;
  }

  bool get isComplete => subExams.every((s) => s.grade != null);

  Subject copyWith({List<SubExam>? subExams}) {
    return Subject(
      name: name,
      nameKey: nameKey,
      coefficient: coefficient,
      subExams: subExams ?? this.subExams,
    );
  }
}