import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _parchment   = Color(0xFFF5E6C8);
  static const Color _parchmentDk = Color(0xFFEDD9A3);
  static const Color _espresso    = Color(0xFF2C1A0E);
  static const Color _espressoLt  = Color(0xFF4A2E1A);
  static const Color _brass       = Color(0xFFB8860B);
  static const Color _inkFaded    = Color(0xFF6B4C35);
  static const Color _marble      = Color(0xFFFAF0DC);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final s = provider.strings;
    final isRtl = provider.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _parchment,
        appBar: AppBar(
          backgroundColor: _espresso,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: _parchmentDk,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            s.settingsTitle,
            style: _playfair(
              color: _parchmentDk,
              fontSize: 16,
              weight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            _buildSectionHeader(s.languageSection, isRtl),
            const SizedBox(height: 12),
            _buildLanguageTile(
              context,
              provider: provider,
              language: AppLanguage.fr,
              label: s.langFr,
              nativeLabel: 'Français',
              isRtl: isRtl,
            ),
            const SizedBox(height: 8),
            _buildLanguageTile(
              context,
              provider: provider,
              language: AppLanguage.ar,
              label: s.langAr,
              nativeLabel: 'العربية',
              isRtl: isRtl,
            ),
            const SizedBox(height: 8),
            _buildLanguageTile(
              context,
              provider: provider,
              language: AppLanguage.en,
              label: s.langEn,
              nativeLabel: 'English',
              isRtl: isRtl,
            ),
            const SizedBox(height: 32),
            _buildOrnamentDivider(),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'za3ma ndoubel',
                style: _lora(
                  color: _inkFaded.withValues(alpha: 0.4),
                  fontSize: 11,
                  style: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isRtl) {
    return Row(
      children: [
        Container(width: 3, height: 16, color: const Color(0xFFB8860B)),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: _lora(
            color: _inkFaded,
            fontSize: 10,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTile(
      BuildContext context, {
        required LocaleProvider provider,
        required AppLanguage language,
        required String label,
        required String nativeLabel,
        required bool isRtl,
      }) {
    final isSelected = provider.language == language;

    return GestureDetector(
      onTap: () => provider.setLanguage(language),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _espresso : _marble,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? _brass : _parchmentDk,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _espresso.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeLabel,
                  style: _playfair(
                    color: isSelected ? _brass : _espresso,
                    fontSize: 15,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: _lora(
                    color: isSelected
                        ? _parchmentDk.withValues(alpha: 0.7)
                        : _inkFaded,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _brass,
                  shape: BoxShape.circle,
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _inkFaded.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnamentDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1,
          color: _inkFaded.withValues(alpha: 0.2),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: _inkFaded.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Container(
          width: 40,
          height: 1,
          color: _inkFaded.withValues(alpha: 0.2),
        ),
      ],
    );
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
}