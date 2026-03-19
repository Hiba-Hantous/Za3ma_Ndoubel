enum AppLanguage { fr, ar, en }

class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  // ── App ───────────────────────────────────────────────────────────────────

  String get appTitle => const {
    AppLanguage.fr: 'Moyenne — Finance & Gestion',
    AppLanguage.ar: 'المعدّل — مالية وتصرف',
    AppLanguage.en: 'Average — Finance & Management',
  }[language]!;

  String get screenTitle => const {
    AppLanguage.fr: 'Moyenne du Trimestre',
    AppLanguage.ar: 'معدّل الثلاثي',
    AppLanguage.en: 'Trimester Average',
  }[language]!;

  String get screenSubtitle => const {
    AppLanguage.fr: '✦  المعدّل  ✦',
    AppLanguage.ar: '✦  المعدّل  ✦',
    AppLanguage.en: '✦  Average  ✦',
  }[language]!;

  // ── Average panel ─────────────────────────────────────────────────────────

  String get generalAverage => const {
    AppLanguage.fr: 'Moyenne Générale',
    AppLanguage.ar: 'المعدّل العام',
    AppLanguage.en: 'General Average',
  }[language]!;

  String get partialPreview => const {
    AppLanguage.fr: 'Aperçu partiel',
    AppLanguage.ar: 'معاينة جزئية',
    AppLanguage.en: 'Partial preview',
  }[language]!;

  String get completeAllGrades => const {
    AppLanguage.fr: 'Complétez toutes les notes',
    AppLanguage.ar: 'أكمل جميع النقاط',
    AppLanguage.en: 'Complete all grades',
  }[language]!;

  String get enterYourGrades => const {
    AppLanguage.fr: 'Entrez vos notes',
    AppLanguage.ar: 'أدخل نقاطك',
    AppLanguage.en: 'Enter your grades',
  }[language]!;

  String get analysisTitle => const {
    AppLanguage.fr: 'Analyse de tes résultats',
    AppLanguage.ar: 'تحليل نتائجك',
    AppLanguage.en: 'Your results analysis',
  }[language]!;

  String get analysisLoading => const {
    AppLanguage.fr: 'Consultation en cours...',
    AppLanguage.ar: 'جاري التحليل...',
    AppLanguage.en: 'Analysing your grades...',
  }[language]!;

  String get analysisError => const {
    AppLanguage.fr: 'Une erreur est survenue. Réessaie.',
    AppLanguage.ar: 'حدث خطأ. حاول مجدداً.',
    AppLanguage.en: 'Something went wrong. Please retry.',
  }[language]!;

  String get retry => const {
    AppLanguage.fr: 'Réessayer',
    AppLanguage.ar: 'إعادة المحاولة',
    AppLanguage.en: 'Retry',
  }[language]!;

  String get analyseButton => const {
    AppLanguage.fr: 'Analyser mes résultats',
    AppLanguage.ar: 'تحليل نتائجي',
    AppLanguage.en: 'Analyse my results',
  }[language]!;

  // ── Subject card ──────────────────────────────────────────────────────────

  String moduleAverage(String value) => {
    AppLanguage.fr: 'Moy. module : $value',
    AppLanguage.ar: 'معدّل الوحدة : $value',
    AppLanguage.en: 'Module avg: $value',
  }[language]!;

  String coeff(double c) {
    final display = c % 1 == 0 ? c.toInt().toString() : c.toString();
    return {
      AppLanguage.fr: 'Coeff. $display',
      AppLanguage.ar: 'المعامل $display',
      AppLanguage.en: 'Coeff. $display',
    }[language]!;
  }

  // ── Grade input ───────────────────────────────────────────────────────────

  String get gradHint => const {
    AppLanguage.fr: '/20',
    AppLanguage.ar: '/20',
    AppLanguage.en: '/20',
  }[language]!;

  String get invalidGrade => const {
    AppLanguage.fr: 'Note invalide (0-20)',
    AppLanguage.ar: 'نقطة غير صالحة (0-20)',
    AppLanguage.en: 'Invalid grade (0-20)',
  }[language]!;

  // ── Annual average ────────────────────────────────────────────────────────

  String get annualAverageTitle => const {
    AppLanguage.fr: 'Moyenne Annuelle',
    AppLanguage.ar: 'المعدل السنوي',
    AppLanguage.en: 'Annual Average',
  }[language]!;

  String get generalAverageAnnual => const {
    AppLanguage.fr: 'Moyenne de l\'année',
    AppLanguage.ar: 'معدل السنة',
    AppLanguage.en: 'Year Average',
  }[language]!;

  String trimestre(int n) => {
    AppLanguage.fr: 'Trimestre $n',
    AppLanguage.ar: 'الثلاثي $n',
    AppLanguage.en: 'Trimester $n',
  }[language]!;

  String get annualAverageButton => const {
    AppLanguage.fr: 'Moyenne annuelle',
    AppLanguage.ar: 'المعدل السنوي',
    AppLanguage.en: 'Annual average',
  }[language]!;

  String get weakestTrimester => const {
    AppLanguage.fr: 'Trimestre le plus faible',
    AppLanguage.ar: 'أضعف ثلاثي',
    AppLanguage.en: 'Weakest trimester',
  }[language]!;

  // ── Buttons ───────────────────────────────────────────────────────────────

  String get clearAll => const {
    AppLanguage.fr: 'Effacer tout',
    AppLanguage.ar: 'مسح الكل',
    AppLanguage.en: 'Clear all',
  }[language]!;

  String get settings => const {
    AppLanguage.fr: 'Paramètres',
    AppLanguage.ar: 'الإعدادات',
    AppLanguage.en: 'Settings',
  }[language]!;

  // ── Mentions ──────────────────────────────────────────────────────────────

  String mention(double average) {
    final key = _mentionKey(average);
    return {
      AppLanguage.fr: {
        'tres_bien': 'Très Bien',
        'bien': 'Bien',
        'assez_bien': 'Assez Bien',
        'passable': 'Passable',
        'insuffisant': 'Insuffisant',
      },
      AppLanguage.ar: {
        'tres_bien': 'ممتاز',
        'bien': 'جيد جداً',
        'assez_bien': 'جيد',
        'passable': 'مقبول',
        'insuffisant': 'ضعيف',
      },
      AppLanguage.en: {
        'tres_bien': 'Excellent',
        'bien': 'Good',
        'assez_bien': 'Fairly Good',
        'passable': 'Pass',
        'insuffisant': 'Fail',
      },
    }[language]![key]!;
  }

  String _mentionKey(double average) {
    if (average >= 18) return 'tres_bien';
    if (average >= 16) return 'bien';
    if (average >= 14) return 'assez_bien';
    if (average >= 10) return 'passable';
    return 'insuffisant';
  }

  // ── Settings screen ───────────────────────────────────────────────────────

  String get settingsTitle => const {
    AppLanguage.fr: 'Paramètres',
    AppLanguage.ar: 'الإعدادات',
    AppLanguage.en: 'Settings',
  }[language]!;

  String get languageSection => const {
    AppLanguage.fr: 'Langue',
    AppLanguage.ar: 'اللغة',
    AppLanguage.en: 'Language',
  }[language]!;

  String get langFr => const {
    AppLanguage.fr: 'Français',
    AppLanguage.ar: 'الفرنسية',
    AppLanguage.en: 'French',
  }[language]!;

  String get langAr => const {
    AppLanguage.fr: 'Arabe',
    AppLanguage.ar: 'العربية',
    AppLanguage.en: 'Arabic',
  }[language]!;

  String get langEn => const {
    AppLanguage.fr: 'Anglais',
    AppLanguage.ar: 'الإنجليزية',
    AppLanguage.en: 'English',
  }[language]!;

  // ── Subject names ─────────────────────────────────────────────────────────

  String subjectName(String key) => {
    AppLanguage.fr: _subjectsFr,
    AppLanguage.ar: _subjectsAr,
    AppLanguage.en: _subjectsEn,
  }[language]![key] ?? key;

  static const _subjectsFr = {
    'eco': 'Économie',
    'gestion': 'Gestion',
    'math': 'Mathématiques',
    'francais': 'Français',
    'arabe': 'Arabe',
    'anglais': 'Anglais',
    'informatique': 'Informatique',
    'histoire': 'Histoire',
    'geo': 'Géographie',
    'ed_civique': 'Éducation Civique',
    'pensee_islamique': 'Pensée Islamique',
    'sport': 'Sport',
  };

  static const _subjectsAr = {
    'eco': 'اقتصاد',
    'gestion': 'تصرف',
    'math': 'رياضيات',
    'francais': 'فرنسية',
    'arabe': 'عربية',
    'anglais': 'انجليزية',
    'informatique': 'اعلامية',
    'histoire': 'تاريخ',
    'geo': 'جغرافيا',
    'ed_civique': 'تربية مدنية',
    'pensee_islamique': 'فكر اسلامي',
    'sport': 'تربية بدنية',
  };

  static const _subjectsEn = {
    'eco': 'Economics',
    'gestion': 'Management',
    'math': 'Mathematics',
    'francais': 'French',
    'arabe': 'Arabic',
    'anglais': 'English',
    'informatique': 'Computer Science',
    'histoire': 'History',
    'geo': 'Geography',
    'ed_civique': 'Civic Education',
    'pensee_islamique': 'Islamic Thought',
    'sport': 'Sport',
  };

  // ── Sub-exam names ────────────────────────────────────────────────────────

  String subExamName(String key) => {
    AppLanguage.fr: _subExamsFr,
    AppLanguage.ar: _subExamsAr,
    AppLanguage.en: _subExamsEn,
  }[language]![key] ?? key;

  static const _subExamsFr = {
    'tp_projet': 'TP (Note Projet)',
    'controle': 'Contrôle',
    'synthese': 'Synthèse',
    'controle_1': 'Contrôle 1',
    'controle_2': 'Contrôle 2',
    'oral': 'Oral',
    'tp': 'TP',
  };

  static const _subExamsAr = {
    'tp_projet': 'عمل تطبيقي (مشروع)',
    'controle': 'فرض',
    'synthese': 'امتحان تأليفي',
    'controle_1': 'فرض 1',
    'controle_2': 'فرض 2',
    'oral': 'شفاهي',
    'tp': 'عمل تطبيقي',
  };

  static const _subExamsEn = {
    'tp_projet': 'Project Work',
    'controle': 'Test',
    'synthese': 'Synthesis Exam',
    'controle_1': 'Test 1',
    'controle_2': 'Test 2',
    'oral': 'Oral',
    'tp': 'Practical Work',
  };

}