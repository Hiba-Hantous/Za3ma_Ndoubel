import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';
import '../l10n/app_strings.dart';
import '../models/subject.dart';
import '../services/session_service.dart';
import '../data/finance_subjects.dart';
import '../utils/grade_calculator.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static Future<String> analyseGrades({
    required List<Subject> subjects,
    required AppLanguage language,
    required int currentTrimester,
  }) async {
    final allTrimesterAverages = await _loadAllTrimesterAverages(currentTrimester, subjects);
    final prompt = _buildPrompt(subjects, language, currentTrimester, allTrimesterAverages);

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 3000,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      final finishReason = data['candidates']?[0]?['finishReason'];

      if (text != null && finishReason == 'STOP') {
        return text.trim();
      } else if (text != null && finishReason == 'MAX_TOKENS') {
        return text.trim() + '...';
      }
      throw Exception('Empty response from Gemini');
    } else {
      debugPrint('GEMINI STATUS: ${response.statusCode}');
      debugPrint('GEMINI BODY: ${response.body}');
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }
  }

  // ── Load all trimester averages from saved sessions ───────────────────────

  static Future<Map<int, double>> _loadAllTrimesterAverages(
      int currentTrimester,
      List<Subject> currentSubjects,
      ) async {
    final Map<int, double> averages = {};

    for (int t = 1; t <= 3; t++) {
      if (t == currentTrimester) {
        final avg = calculateTrimesterAverage(currentSubjects);
        if (avg != null) averages[t] = avg;
      } else {
        final subjects = buildFinanceSubjects();
        final loaded = await SessionService.loadAllGrades(t, subjects);
        final avg = calculateTrimesterAverage(loaded);
        if (avg != null) averages[t] = avg;
      }
    }

    return averages;
  }

  // ── Prompt builder ────────────────────────────────────────────────────────

  static String _buildPrompt(
      List<Subject> subjects,
      AppLanguage language,
      int currentTrimester,
      Map<int, double> allAverages,
      ) {
    final buffer = StringBuffer();

    buffer.writeln(_systemContext(language, currentTrimester));
    buffer.writeln();

    // Current trimester subject breakdown
    buffer.writeln(_currentTrimesterLabel(language, currentTrimester));
    for (final subject in subjects) {
      final avg = calculateModuleAverage(subject);
      if (avg == null) continue;
      buffer.writeln(
          '- ${subject.name} (coeff ${subject.coefficient}) : ${avg.toStringAsFixed(2)}/20');
    }

    final currentAvg = calculateTrimesterAverage(subjects);
    if (currentAvg != null) {
      buffer.writeln();
      buffer.writeln(_averageLabel(language) + currentAvg.toStringAsFixed(2) + '/20');
    }

    // Other available trimester averages
    final otherTrimesters = allAverages.entries.where((e) => e.key != currentTrimester);
    if (otherTrimesters.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(_otherTrimestersLabel(language));
      for (final entry in otherTrimesters) {
        buffer.writeln('- Trimestre ${entry.key} : ${entry.value.toStringAsFixed(2)}/20');
      }

      // Annual average if all three available
      if (allAverages.length == 3) {
        final t1 = allAverages[1]!;
        final t2 = allAverages[2]!;
        final t3 = allAverages[3]!;
        final annual = (t1 * 1 + t2 * 2 + t3 * 2) / 5;
        buffer.writeln();
        buffer.writeln(_annualLabel(language) + annual.toStringAsFixed(2) + '/20');
      }
    }

    buffer.writeln();
    buffer.writeln(_instructions(language, currentTrimester, allAverages));

    return buffer.toString();
  }

  // ── System context ────────────────────────────────────────────────────────

  static String _systemContext(AppLanguage language, int trimester) => {
    AppLanguage.fr:
    "Tu es un conseiller pédagogique tunisien pour un élève en "
        "2ème année baccalauréat, section Finance et Gestion. "
        "Tu es compétent, direct et un peu taquin — tu parles à l'élève "
        "comme un grand frère qui s'y connaît, pas comme un robot. "
        "Tu utilises parfois des expressions tunisiennes francisées "
        "mais tu restes professionnel sur le fond. "
        "Tu connais parfaitement le programme tunisien du bac et ses exigences. "
        "L'élève est actuellement au trimestre $trimester.",
    AppLanguage.ar:
    "أنت مستشار تربوي تونسي لتلميذ في السنة الثانية باكالوريا، "
        "شعبة المالية والتصرف. "
        "تعطي نصائح جدية ومفيدة، لكنك تتكلم بصراحة وخفة دم — "
        "مثل الأخ الكبير اللي يعرف شنوّا يقول. "
        "تعرف البرنامج التونسي للباكالوريا جيداً ومتطلباته. "
        "التلميذ حالياً في الثلاثي $trimester.",
    AppLanguage.en:
    "You are a Tunisian academic advisor for a student in "
        "2nd year baccalaureate, Finance and Management stream. "
        "You give serious, useful advice but with a direct and slightly "
        "teasing tone — like an older sibling who knows their stuff. "
        "You know the Tunisian baccalaureate programme and its requirements well. "
        "The student is currently in trimester $trimester.",
  }[language]!;

  // ── Labels ────────────────────────────────────────────────────────────────

  static String _currentTrimesterLabel(AppLanguage language, int t) => {
    AppLanguage.fr: 'Résultats du trimestre $t (en cours) :',
    AppLanguage.ar: 'نتائج الثلاثي $t (الحالي):',
    AppLanguage.en: 'Trimester $t results (current):',
  }[language]!;

  static String _otherTrimestersLabel(AppLanguage language) => {
    AppLanguage.fr: 'Moyennes des autres trimestres :',
    AppLanguage.ar: 'معدلات الثلاثيات الأخرى:',
    AppLanguage.en: 'Other trimester averages:',
  }[language]!;

  static String _annualLabel(AppLanguage language) => {
    AppLanguage.fr: 'Moyenne annuelle provisoire : ',
    AppLanguage.ar: 'المعدل السنوي المؤقت: ',
    AppLanguage.en: 'Provisional annual average: ',
  }[language]!;

  static String _averageLabel(AppLanguage language) => {
    AppLanguage.fr: 'Moyenne générale du trimestre : ',
    AppLanguage.ar: 'المعدل العام للثلاثي: ',
    AppLanguage.en: 'Overall trimester average: ',
  }[language]!;

  // ── Instructions ──────────────────────────────────────────────────────────

  static String _instructions(
      AppLanguage language,
      int trimester,
      Map<int, double> allAverages,
      ) {
    final hasMultiple = allAverages.length > 1;
    final isLast = trimester == 3;

    return {
      AppLanguage.fr: _instructionsFr(trimester, hasMultiple, isLast),
      AppLanguage.ar: _instructionsAr(trimester, hasMultiple, isLast),
      AppLanguage.en: _instructionsEn(trimester, hasMultiple, isLast),
    }[language]!;
  }

  static String _instructionsFr(int trimester, bool hasMultiple, bool isLast) =>
      "Rédige une analyse structurée en ${isLast ? '4' : '3'} parties, "
          "sans titres markdown, sans emojis, texte simple uniquement.\n\n"
          "Partie 1 — Diagnostic honnête : "
          "Identifie les 2 ou 3 matières les plus problématiques en tenant compte des coefficients. "
          "Sois direct et un peu taquin si c'est mérité. "
          "Explique pourquoi ces matières sont critiques pour la moyenne finale."
          "${hasMultiple ? ' Si d\'autres trimestres sont disponibles, commente la tendance (amélioration ou régression).' : ''}\n\n"
          "Partie 2 — Plan de travail concret : "
          "Pour chaque matière faible, donne des points de renforcement précis liés au programme tunisien. "
          "Propose une organisation hebdomadaire réaliste avec nombre d'heures, "
          "équilibre mémorisation/exercices, préparation à la synthèse. "
          "Mentionne : annales du bac tunisien, fiches de révision, exercices types.\n\n"
          "Partie 3 — ${isLast ? 'Bilan annuel' : 'Objectif trimestre suivant'} : "
          "${isLast
          ? 'Fais un bilan de l\'année entière. Identifie les points forts à maintenir et les axes de progression. '
          'Donne des conseils concrets pour bien aborder les révisions finales du bac.'
          : 'Fixe un objectif réaliste pour le trimestre ${trimester + 1}. '
          'Dis-lui clairement ce qu\'il faut améliorer en priorité et de combien de points.'}\n\n"
          "Partie finale — Mot de fin : "
          "Termine avec une conclusion motivante mais réaliste. Pas de faux espoir.";

  static String _instructionsAr(int trimester, bool hasMultiple, bool isLast) =>
      "اكتب تحليلاً منظماً في ${isLast ? '4' : '3'} أجزاء، بدون عناوين، بدون رموز، نص عادي فقط.\n\n"
          "الجزء 1 — تشخيص صريح: "
          "حدد المادتين أو الثلاث مواد الأكثر إشكالية مع مراعاة المعاملات. "
          "كن صريحاً وفيها شوية دعابة تونسية إذا استحق الأمر. "
          "اشرح لماذا هذه المواد حاسمة للمعدل النهائي."
          "${hasMultiple ? ' إذا توفرت ثلاثيات أخرى، علّق على الاتجاه العام (تحسن أم تراجع).' : ''}\n\n"
          "الجزء 2 — خطة عمل ملموسة: "
          "لكل مادة ضعيفة أعطِ نقاط تقوية محددة مرتبطة بالبرنامج التونسي. "
          "اقترح تنظيماً أسبوعياً واقعياً مع عدد الساعات والتوازن بين المراجعة والتمارين. "
          "اذكر: مواضيع باكالوريا سابقة، بطاقات مراجعة، تمارين نموذجية.\n\n"
          "الجزء 3 — ${isLast ? 'تقييم سنوي' : 'هدف الثلاثي القادم'}: "
          "${isLast
          ? 'قدّم تقييماً للسنة كاملة. حدد نقاط القوة للحفاظ عليها ومحاور التحسين. '
          'أعطِ نصائح ملموسة للتحضير للامتحانات النهائية.'
          : 'حدد هدفاً واقعياً للثلاثي ${trimester + 1}. '
          'قل له بوضوح ما يجب تحسينه بالأولوية وبكم نقطة.'}\n\n"
          "الجزء الأخير — كلمة ختامية: "
          "اختم بتشجيع واقعي. بلا وعود فارغة.";

  static String _instructionsEn(int trimester, bool hasMultiple, bool isLast) =>
      "Write a structured analysis in ${isLast ? '4' : '3'} parts, "
          "no markdown titles, no emojis, plain text only.\n\n"
          "Part 1 — Honest diagnosis: "
          "Identify the 2 or 3 most problematic subjects taking coefficients into account. "
          "Be direct with a light Tunisian-style tease if deserved. "
          "Explain why these subjects are critical for the final average."
          "${hasMultiple ? ' If other trimesters are available, comment on the trend (improving or declining).' : ''}\n\n"
          "Part 2 — Concrete study plan: "
          "For each weak subject give specific reinforcement points tied to the Tunisian bac programme. "
          "Suggest a realistic weekly schedule with hours per subject, "
          "memorisation/exercise balance, synthesis exam preparation. "
          "Mention: past Tunisian bac papers, revision sheets, past exam questions.\n\n"
          "Part ${isLast ? '3 — Annual review' : '3 — Next trimester target'}: "
          "${isLast
          ? 'Give a full year review. Identify strengths to maintain and areas for improvement. '
          'Give concrete advice for approaching the final bac revision.'
          : 'Set a realistic target for trimester ${trimester + 1}. '
          'Tell them clearly what to prioritise and by how many points.'}\n\n"
          "Final part — Closing word: "
          "End with a motivating but realistic conclusion. No empty promises.";
}