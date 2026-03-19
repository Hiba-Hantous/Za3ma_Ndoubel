import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/finance_subjects.dart';
import '../models/subject.dart';
import '../providers/locale_provider.dart';
import '../providers/trimester_provider.dart';
import '../services/session_service.dart';
import '../utils/grade_calculator.dart';
import 'settings_screen.dart';
import 'analysis_sheet.dart';
import 'annual_average_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late List<Subject> _subjects;
  bool _isLoading = true;
  bool _appBarExpanded = true;
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  final Map<String, FocusNode> _firstFieldFocus = {};
  final ScrollController _scrollController = ScrollController();

  static const Color _parchment   = Color(0xFFF5E6C8);
  static const Color _parchmentDk = Color(0xFFEDD9A3);
  static const Color _espresso    = Color(0xFF2C1A0E);
  static const Color _espressoLt  = Color(0xFF4A2E1A);
  static const Color _brass       = Color(0xFFB8860B);
  static const Color _terracotta  = Color(0xFFC4724A);
  static const Color _inkFaded    = Color(0xFF6B4C35);
  static const Color _marble      = Color(0xFFFAF0DC);

  // ── Font helpers ──────────────────────────────────────────────────────────

  static TextStyle _playfair({
    double fontSize = 14,
    FontWeight weight = FontWeight.w400,
    Color color = _espresso,
    double? height,
    double letterSpacing = 0,
    FontStyle style = FontStyle.normal,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: style,
      );

  static TextStyle _lora({
    double fontSize = 14,
    FontWeight weight = FontWeight.w400,
    Color color = _espresso,
    double letterSpacing = 0,
    FontStyle style = FontStyle.normal,
  }) =>
      GoogleFonts.lora(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: style,
      );

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _subjects = buildFinanceSubjects();
    for (final subject in _subjects) {
      _controllers[subject.name] = {};
      for (final sub in subject.subExams) {
        _controllers[subject.name]![sub.name] = TextEditingController()
          ..addListener(_onGradeChanged);
      }
      _firstFieldFocus[subject.name] = FocusNode();
    }
    _scrollController.addListener(_onScroll);
    Future.microtask(() => _loadSession());
  }

  @override
  void dispose() {
    for (final subMap in _controllers.values) {
      for (final ctrl in subMap.values) {
        ctrl.dispose();
      }
    }
    for (final fn in _firstFieldFocus.values) {
      fn.dispose();
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 160.0 - kToolbarHeight;
    final expanded = !_scrollController.hasClients ||
        _scrollController.offset < threshold;
    if (expanded != _appBarExpanded) {
      setState(() => _appBarExpanded = expanded);
    }
  }

  Future<void> _loadSession() async {
    if (!mounted) return;
    final trimester = context.read<TrimesterProvider>().trimester;
    final loaded = await SessionService.loadAllGrades(trimester, _subjects);
    if (!mounted) return;
    for (final subject in loaded) {
      for (final sub in subject.subExams) {
        final ctrl = _controllers[subject.name]![sub.name]!;
        ctrl.removeListener(_onGradeChanged);
        ctrl.text = sub.grade != null ? sub.grade.toString() : '';
        ctrl.addListener(_onGradeChanged);
      }
    }
    setState(() {
      _subjects = loaded;
      _isLoading = false;
    });
  }

  void _switchTrimester(int t) {
    context.read<TrimesterProvider>().setTrimester(t);
    for (final subMap in _controllers.values) {
      for (final ctrl in subMap.values) {
        ctrl.removeListener(_onGradeChanged);
        ctrl.clear();
        ctrl.addListener(_onGradeChanged);
      }
    }
    setState(() {
      _subjects = buildFinanceSubjects();
      _isLoading = true;
    });
    _loadSession();
  }

  void _validateGrade(TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null || value < 0 || value > 20) {
      ctrl.clear();
      final s = context.read<LocaleProvider>().strings;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(s.invalidGrade),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  void _onGradeChanged() {
    setState(() {
      _syncGradesToModel();
    });
    final trimester = context.read<TrimesterProvider>().trimester;
    SessionService.saveAllGrades(trimester, _subjects);
  }

  void _syncGradesToModel() {
    for (int i = 0; i < _subjects.length; i++) {
      final subject = _subjects[i];
      final updatedSubs = subject.subExams.map((sub) {
        final text = _controllers[subject.name]![sub.name]!.text.trim();
        final grade = double.tryParse(text.replaceAll(',', '.'));
        return sub.copyWith(grade: grade);
      }).toList();
      _subjects[i] = subject.copyWith(subExams: updatedSubs);
    }
  }

  void _clearAll() {
    for (final subMap in _controllers.values) {
      for (final ctrl in subMap.values) {
        ctrl.clear();
      }
    }
    setState(() {
      _subjects = buildFinanceSubjects();
    });
    final trimester = context.read<TrimesterProvider>().trimester;
    SessionService.clearTrimester(trimester);
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final s = provider.strings;
    final isRtl = provider.isRtl;
    final trimester = context.watch<TrimesterProvider>().trimester;
    final partial = calculatePartialTrimesterAverage(_subjects);
    final full = calculateTrimesterAverage(_subjects);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _parchment,
        floatingActionButton: FloatingActionButton.small(
          onPressed: () => _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          ),
          backgroundColor: _espresso,
          foregroundColor: _brass,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.keyboard_arrow_up_rounded),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _brass))
            : CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(s, isRtl, trimester),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAveragePanel(s, partial, full),
                  const SizedBox(height: 20),
                  ..._subjects.map((sub) => _buildSubjectCard(s, sub)),
                  const SizedBox(height: 24),
                  _buildAnalyseButton(s, full != null),
                  const SizedBox(height: 12),
                  _buildAnnualButton(s),
                  const SizedBox(height: 12),
                  _buildClearButton(s),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(dynamic s, bool isRtl, int trimester) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: _espresso,
      automaticallyImplyLeading: false,
      actions: [
        IgnorePointer(
          ignoring: !_appBarExpanded,
          child: AnimatedOpacity(
            opacity: _appBarExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [1, 2, 3].map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                child: GestureDetector(
                  onTap: () => _switchTrimester(t),
                  child: Container(
                    width: 32,
                    height: 26,
                    decoration: BoxDecoration(
                      color: trimester == t ? _espresso : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                      border: trimester == t
                          ? Border.all(color: _brass, width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'T$t',
                        style: _lora(
                          fontSize: 11,
                          color: trimester == t ? _brass : _parchmentDk,
                        ),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: _parchmentDk, size: 20),
          tooltip: s.settings,
          onPressed: _openSettings,
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: _parchmentDk, size: 20),
          tooltip: s.clearAll,
          onPressed: _clearAll,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              s.screenSubtitle,
              style: _lora(
                color: _brass,
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
            Text(
              s.screenTitle,
              style: _playfair(
                color: _parchment,
                fontSize: 15,
                weight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A04), _espresso],
            ),
          ),
          child: Center(
            child: Opacity(
              opacity: 0.07,
              child: _TilePattern(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Average Panel ─────────────────────────────────────────────────────────

  Widget _buildAveragePanel(dynamic s, double? partial, double? full) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: _espresso,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _brass.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _espresso.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: _OrnamentDivider(color: _brass.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),

          if (full != null) ...[
            Text(
              s.generalAverage,
              style: _lora(
                color: _parchmentDk,
                fontSize: 11,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              full.toStringAsFixed(2),
              style: _playfair(
                color: _brass,
                fontSize: 52,
                weight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.mention(full),
              style: _lora(
                color: _terracotta,
                fontSize: 14,
                style: FontStyle.italic,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
          ] else if (partial != null) ...[
            Text(
              s.partialPreview,
              style: _lora(
                color: _parchmentDk.withValues(alpha: 0.6),
                fontSize: 10,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              partial.toStringAsFixed(2),
              style: _playfair(
                color: _brass.withValues(alpha: 0.5),
                fontSize: 48,
                weight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.completeAllGrades,
              style: _lora(
                color: _inkFaded.withValues(alpha: 0.7),
                fontSize: 11,
                style: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              '- -',
              style: _playfair(
                color: _brass.withValues(alpha: 0.3),
                fontSize: 40,
                weight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.enterYourGrades,
              style: _lora(
                color: _inkFaded.withValues(alpha: 0.5),
                fontSize: 12,
                style: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
          ],

          _OrnamentDivider(color: _brass.withValues(alpha: 0.5)),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  // ── Subject Card ──────────────────────────────────────────────────────────

  Widget _buildSubjectCard(dynamic s, Subject subject) {
    final avg = calculateModuleAverage(subject);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _marble,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _parchmentDk, width: 1),
        boxShadow: [
          BoxShadow(
            color: _espresso.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: _CoeffBadge(coeff: subject.coefficient),
          title: Text(
            s.subjectName(subject.nameKey),
            style: _playfair(
              color: _espresso,
              fontSize: 15,
              weight: FontWeight.w700,
            ),
          ),
          subtitle: avg != null
              ? Text(
            s.moduleAverage(avg.toStringAsFixed(2)),
            style: _lora(
              color: _terracotta,
              fontSize: 11,
              style: FontStyle.italic,
            ),
          )
              : Text(
            s.coeff(subject.coefficient),
            style: _lora(
              color: _inkFaded.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          iconColor: _brass,
          collapsedIconColor: _inkFaded,
          onExpansionChanged: (expanded) {
            if (expanded) {
              Future.delayed(const Duration(milliseconds: 100), () {
                _firstFieldFocus[subject.name]?.requestFocus();
              });
            }
          },
          children: subject.subExams
              .map((sub) => _buildSubExamRow(s, subject, sub))
              .toList(),
        ),
      ),
    );
  }

  // ── Sub-Exam Row ──────────────────────────────────────────────────────────

  Widget _buildSubExamRow(dynamic s, Subject subject, SubExam sub) {
    final ctrl = _controllers[subject.name]![sub.name]!;
    final isFirst = sub.name == subject.subExams.first.name;
    final focusNode = isFirst ? _firstFieldFocus[subject.name] : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.subExamName(sub.nameKey),
                  style: _lora(color: _espressoLt, fontSize: 13),
                ),
                Text(
                  '× ${sub.coefficient % 1 == 0 ? sub.coefficient.toInt() : sub.coefficient}',
                  style: _lora(
                    color: _inkFaded.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) _validateGrade(ctrl);
              },
              child: TextFormField(
                controller: ctrl,
                focusNode: focusNode,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                textAlign: TextAlign.center,
                style: _playfair(
                  color: _espresso,
                  fontSize: 15,
                  weight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: s.gradHint,
                  hintStyle: _lora(
                    color: _inkFaded.withValues(alpha: 0.35),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: _parchment,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: const BorderSide(color: _parchmentDk),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: const BorderSide(color: _parchmentDk),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: const BorderSide(color: _brass, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Annual Average ────────────────────────────────────────────────────────

  void _openAnnualAverage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LocaleProvider>(),
        child: const AnnualAverageSheet(),
      ),
    );
  }

  Widget _buildAnnualButton(dynamic s) {
    return Center(
      child: OutlinedButton(
        onPressed: _openAnnualAverage,
        style: OutlinedButton.styleFrom(
          foregroundColor: _inkFaded,
          side: const BorderSide(color: _inkFaded, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3)),
        ),
        child: Text(
          s.annualAverageButton,
          style: _lora(
            fontSize: 13,
            letterSpacing: 1.5,
            color: _inkFaded,
          ),
        ),
      ),
    );
  }

  // ── Clear Button ──────────────────────────────────────────────────────────

  void _openAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LocaleProvider>(),
        child: AnalysisSheet(subjects: List.from(_subjects)),
      ),
    );
  }

  // ── Analyse Button ────────────────────────────────────────────────────────

  Widget _buildAnalyseButton(dynamic s, bool allFilled) {
    return Center(
      child: AnimatedOpacity(
        opacity: allFilled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: allFilled ? _openAnalysis : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: allFilled ? _espresso : _inkFaded,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: allFilled ? _brass : _inkFaded,
                width: 1,
              ),
              boxShadow: allFilled
                  ? [
                BoxShadow(
                  color: _espresso.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.analyseButton,
                  style: _lora(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: allFilled ? _parchmentDk : _parchment,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Clear Button ──────────────────────────────────────────────────────────

  Widget _buildClearButton(dynamic s) {
    return Center(
      child: OutlinedButton(
        onPressed: _clearAll,
        style: OutlinedButton.styleFrom(
          foregroundColor: _inkFaded,
          side: const BorderSide(color: _inkFaded, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3)),
        ),
        child: Text(
          s.clearAll,
          style: _lora(
            fontSize: 13,
            letterSpacing: 1.5,
            color: _inkFaded,
          ),
        ),
      ),
    );
  }
}

// ── Ornament Divider ──────────────────────────────────────────────────────────

class _OrnamentDivider extends StatelessWidget {
  final Color color;
  const _OrnamentDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Container(width: 40, height: 1, color: color),
      ],
    );
  }
}

// ── Coefficient Badge ─────────────────────────────────────────────────────────

class _CoeffBadge extends StatelessWidget {
  final double coeff;
  const _CoeffBadge({required this.coeff});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB8860B), width: 1),
        borderRadius: BorderRadius.circular(3),
        color: const Color(0xFF2C1A0E),
      ),
      child: Center(
        child: Text(
          coeff % 1 == 0 ? coeff.toInt().toString() : coeff.toString(),
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFB8860B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Tile Pattern ──────────────────────────────────────────────────────────────

class _TilePattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 200),
      painter: _TilePainter(),
    );
  }
}

class _TilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final rect = Rect.fromLTWH(x, y, step, step);
        canvas.drawRect(rect, paint);
        canvas.drawLine(
          Offset(x, y + step / 2),
          Offset(x + step / 2, y),
          paint,
        );
        canvas.drawLine(
          Offset(x + step / 2, y + step),
          Offset(x + step, y + step / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}