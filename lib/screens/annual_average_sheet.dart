import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/finance_subjects.dart';
import '../providers/locale_provider.dart';
import '../services/session_service.dart';
import '../utils/grade_calculator.dart';

class AnnualAverageSheet extends StatefulWidget {
  const AnnualAverageSheet({super.key});

  @override
  State<AnnualAverageSheet> createState() => _AnnualAverageSheetState();
}

class _AnnualAverageSheetState extends State<AnnualAverageSheet> {
  static const Color _parchment   = Color(0xFFF5E6C8);
  static const Color _parchmentDk = Color(0xFFEDD9A3);
  static const Color _espresso    = Color(0xFF2C1A0E);
  static const Color _espressoLt  = Color(0xFF4A2E1A);
  static const Color _brass       = Color(0xFFB8860B);
  static const Color _terracotta  = Color(0xFFC4724A);
  static const Color _inkFaded    = Color(0xFF6B4C35);

  final List<TextEditingController> _controllers =
      List.generate(3, (_) => TextEditingController());

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
    for (final ctrl in _controllers) {
      ctrl.addListener(_onChanged);
    }
    Future.microtask(() => _autoLoad());
  }

  @override
  void dispose() {
    for (final ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _autoLoad() async {
    for (int t = 1; t <= 3; t++) {
      final subjects = buildFinanceSubjects();
      final loaded = await SessionService.loadAllGrades(t, subjects);
      if (!mounted) return;
      final avg = calculateTrimesterAverage(loaded);
      if (avg != null) {
        _controllers[t - 1].text = avg.toStringAsFixed(2);
      }
    }
  }

  void _onChanged() => setState(() {});

  // ── Logic ─────────────────────────────────────────────────────────────────

  double? get _average {
    final v1 = double.tryParse(_controllers[0].text.trim().replaceAll(',', '.'));
    final v2 = double.tryParse(_controllers[1].text.trim().replaceAll(',', '.'));
    final v3 = double.tryParse(_controllers[2].text.trim().replaceAll(',', '.'));
    if (v1 == null || v2 == null || v3 == null) return null;
    return (v1 * 1 + v2 * 2 + v3 * 2) / 5;
  }

  void _validate(TextEditingController ctrl) {
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

  void _clearAll() {
    for (final ctrl in _controllers) {
      ctrl.clear();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final s = provider.strings;
    final isRtl = provider.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: _parchment,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(s),
              const Divider(height: 1, color: Color(0xFFEDD9A3)),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAveragePanel(s),
                      if (_trimesterCards(s) != null) ...[
                        const SizedBox(height: 16),
                        _trimesterCards(s)!,
                      ],
                      const SizedBox(height: 24),
                      _buildRow(1, _controllers[0], s.trimestre(1)),
                      _buildRow(2, _controllers[1], s.trimestre(2)),
                      _buildRow(3, _controllers[2], s.trimestre(3)),
                      const SizedBox(height: 24),
                      _buildClearButton(s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Trimester Cards ───────────────────────────────────────────────────────

  Widget? _trimesterCards(dynamic s) {
    final values = _controllers
        .map((c) => double.tryParse(c.text.trim().replaceAll(',', '.')))
        .toList();
    final filled = values.where((v) => v != null).toList();
    if (filled.length < 2) return null;

    final minVal = filled.reduce((a, b) => a! < b! ? a : b);

    return Row(
      children: List.generate(3, (i) {
        final v = values[i];
        if (v == null) return const Expanded(child: SizedBox());
        final isWeakest = v == minVal;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 4,
              right: i == 2 ? 0 : 4,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _parchment,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isWeakest ? _terracotta : _brass.withValues(alpha: 0.4),
                      width: isWeakest ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'T${i + 1}',
                        style: _playfair(
                          fontSize: 13,
                          weight: FontWeight.w700,
                          color: _brass,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        v.toStringAsFixed(2),
                        style: _lora(
                          fontSize: 12,
                          color: _espressoLt,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWeakest) ...[
                  const SizedBox(height: 4),
                  Text(
                    s.weakestTrimester,
                    style: _lora(
                      fontSize: 9,
                      color: _terracotta,
                      style: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Handle ────────────────────────────────────────────────────────────────

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: _inkFaded.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(dynamic s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            color: _brass,
          ),
          const SizedBox(width: 10),
          Text(
            s.annualAverageTitle,
            style: _playfair(
              fontSize: 16,
              weight: FontWeight.w700,
              color: _espresso,
            ),
          ),
        ],
      ),
    );
  }

  // ── Average Panel ─────────────────────────────────────────────────────────

  Widget _buildAveragePanel(dynamic s) {
    final avg = _average;

    return Container(
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
          if (avg != null) ...[
            Text(
              s.generalAverageAnnual,
              style: _lora(
                color: _parchmentDk,
                fontSize: 11,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              avg.toStringAsFixed(2),
              style: _playfair(
                color: _brass,
                fontSize: 52,
                weight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              s.mention(avg),
              style: _lora(
                color: _terracotta,
                fontSize: 14,
                style: FontStyle.italic,
                letterSpacing: 1,
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

  // ── Trimester Row ─────────────────────────────────────────────────────────

  Widget _buildRow(int n, TextEditingController ctrl, String label) {
    final coeff = n == 1 ? 1 : 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: _brass, width: 1),
              borderRadius: BorderRadius.circular(3),
              color: _espresso,
            ),
            child: Center(
              child: Text(
                '\u00d7$coeff',
                style: GoogleFonts.playfairDisplay(
                  color: _brass,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: _lora(color: _espressoLt, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 90,
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) _validate(ctrl);
              },
              child: TextFormField(
                controller: ctrl,
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
                  hintText: '/20',
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
