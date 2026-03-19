import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';
import 'providers/trimester_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<TrimesterProvider>(create: (_) => TrimesterProvider()),
      ],
      child: const MoyenneApp(),
    ),
  );
}

class MoyenneApp extends StatelessWidget {
  const MoyenneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: provider.strings.appTitle,
      debugShowCheckedModeBanner: false,
      locale: provider.locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        textTheme: GoogleFonts.loraTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1A0E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}