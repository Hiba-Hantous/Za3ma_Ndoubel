import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.fr;

  AppLanguage get language => _language;

  AppStrings get strings => AppStrings(_language);

  bool get isRtl => _language == AppLanguage.ar;

  Locale get locale => const {
    AppLanguage.fr: Locale('fr'),
    AppLanguage.ar: Locale('ar'),
    AppLanguage.en: Locale('en'),
  }[_language]!;

  void setLanguage(AppLanguage lang) {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
  }
}