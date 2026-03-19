import '../models/subject.dart';

List<Subject> buildFinanceSubjects() {
  return [
    Subject(
      name: 'Économie', nameKey: 'eco', coefficient: 3,
      subExams: [
        SubExam(name: 'TP (Note Projet)', nameKey: 'tp_projet', coefficient: 1),
        SubExam(name: 'Contrôle',         nameKey: 'controle',  coefficient: 1),
        SubExam(name: 'Synthèse',         nameKey: 'synthese',  coefficient: 2),
      ],
    ),
    Subject(
      name: 'Gestion', nameKey: 'gestion', coefficient: 3,
      subExams: [
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Mathématiques', nameKey: 'math', coefficient: 2.5,
      subExams: [
        SubExam(name: 'Contrôle 1', nameKey: 'controle_1', coefficient: 1),
        SubExam(name: 'Contrôle 2', nameKey: 'controle_2', coefficient: 1),
        SubExam(name: 'Synthèse',   nameKey: 'synthese',   coefficient: 2),
      ],
    ),
    Subject(
      name: 'Français', nameKey: 'francais', coefficient: 2,
      subExams: [
        SubExam(name: 'Oral',     nameKey: 'oral',     coefficient: 1),
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Arabe', nameKey: 'arabe', coefficient: 2,
      subExams: [
        SubExam(name: 'Oral',     nameKey: 'oral',     coefficient: 1),
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Anglais', nameKey: 'anglais', coefficient: 2,
      subExams: [
        SubExam(name: 'Oral',     nameKey: 'oral',     coefficient: 1),
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Informatique', nameKey: 'informatique', coefficient: 1.5,
      subExams: [
        SubExam(name: 'TP',       nameKey: 'tp',       coefficient: 1),
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
      ],
    ),
    Subject(
      name: 'Histoire', nameKey: 'histoire', coefficient: 1.5,
      subExams: [
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Géographie', nameKey: 'geo', coefficient: 1.5,
      subExams: [
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Éducation Civique', nameKey: 'ed_civique', coefficient: 1,
      subExams: [
        SubExam(name: 'Oral',     nameKey: 'oral',     coefficient: 1),
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Pensée Islamique', nameKey: 'pensee_islamique', coefficient: 1,
      subExams: [
        SubExam(name: 'Oral',     nameKey: 'oral',     coefficient: 1),
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
        SubExam(name: 'Synthèse', nameKey: 'synthese', coefficient: 2),
      ],
    ),
    Subject(
      name: 'Sport', nameKey: 'sport', coefficient: 1,
      subExams: [
        SubExam(name: 'TP',       nameKey: 'tp',       coefficient: 1),
        SubExam(name: 'Contrôle', nameKey: 'controle', coefficient: 1),
      ],
    ),
  ];
}