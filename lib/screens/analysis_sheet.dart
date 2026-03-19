import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/locale_provider.dart';
import '../providers/trimester_provider.dart';
import '../services/gemini_service.dart';

class AnalysisSheet extends StatefulWidget {
  final List<Subject> subjects;
  const AnalysisSheet({super.key, required this.subjects});

  @override
  State<AnalysisSheet> createState() => _AnalysisSheetState();
}

class _AnalysisSheetState extends State<AnalysisSheet> {
  static const Color _parchment   = Color(0xFFF5E6C8);
  static const Color _parchmentDk = Color(0xFFEDD9A3);
  static const Color _espresso    = Color(0xFF2C1A0E);
  static const Color _espressoLt  = Color(0xFF4A2E1A);
  static const Color _brass       = Color(0xFFB8860B);
  static const Color _terracotta  = Color(0xFFC4724A);
  static const Color _inkFaded    = Color(0xFF6B4C35);

  String? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetch());
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final language = context.read<LocaleProvider>().language;
      final currentTrimester = context.read<TrimesterProvider>().trimester;
      final text = await GeminiService.analyseGrades(
        subjects: widget.subjects,
        language: language,
        currentTrimester: currentTrimester,
      );
      if (!mounted) return;
      setState(() {
        _result = text;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Font helpers ──────────────────────────────────────────────────────────

  static TextStyle _playfair({
    double fontSize = 14,
    FontWeight weight = FontWeight.w400,
    Color color = _espresso,
    double letterSpacing = 0,
    FontStyle style = FontStyle.normal,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final s = provider.strings;
    final isRtl = provider.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.93,
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
              _buildHeader(s, isRtl),
              const Divider(height: 1, color: Color(0xFFEDD9A3)),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: _buildBody(s),
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildHeader(dynamic s, bool isRtl) {
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
            s.analysisTitle,
            style: _playfair(
              fontSize: 16,
              weight: FontWeight.w700,
              color: _espresso,
            ),
          ),
          const Spacer(),
          if (!_loading)
            GestureDetector(
              onTap: _fetch,
              child: Text(
                s.retry,
                style: _lora(
                  fontSize: 11,
                  color: _inkFaded,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(dynamic s) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _brass,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.analysisLoading,
              style: _lora(
                fontSize: 12,
                color: _inkFaded,
                style: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              s.analysisError,
              style: _lora(
                fontSize: 13,
                color: _terracotta,
                style: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _fetch,
              style: OutlinedButton.styleFrom(
                foregroundColor: _inkFaded,
                side: const BorderSide(color: _inkFaded, width: 1),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3)),
              ),
              child: Text(
                s.retry,
                style: _lora(fontSize: 12, color: _inkFaded),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrnamentDivider(color: _brass.withValues(alpha: 0.35)),
        const SizedBox(height: 20),
        Text(
          _result ?? '',
          style: _lora(
            fontSize: 14,
            color: _espressoLt,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 24),
        _OrnamentDivider(color: _brass.withValues(alpha: 0.35)),
      ],
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