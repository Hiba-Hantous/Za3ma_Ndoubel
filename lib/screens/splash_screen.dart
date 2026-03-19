import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'calculator_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CalculatorScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SvgPicture.string(
              _logoSvg,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

const String _logoSvg = '''
<svg width="100%" viewBox="0 0 680 420" xmlns="http://www.w3.org/2000/svg">
  <rect width="680" height="420" fill="#2C1A0E" rx="16"/>
  <rect x="30" y="30" width="620" height="360" fill="none" stroke="#B8860B" stroke-width="1" rx="10"/>
  <rect x="36" y="36" width="608" height="348" fill="none" stroke="#B8860B" stroke-width="0.4" rx="8" stroke-dasharray="4 6"/>
  <line x1="60" y1="46" x2="60" y2="374" stroke="#B8860B" stroke-width="0.3" opacity="0.3"/>
  <line x1="620" y1="46" x2="620" y2="374" stroke="#B8860B" stroke-width="0.3" opacity="0.3"/>
  <line x1="46" y1="60" x2="634" y2="60" stroke="#B8860B" stroke-width="0.3" opacity="0.3"/>
  <line x1="46" y1="360" x2="634" y2="360" stroke="#B8860B" stroke-width="0.3" opacity="0.3"/>
  <ellipse cx="340" cy="195" rx="115" ry="118" fill="#1A0A04"/>
  <ellipse cx="340" cy="195" rx="115" ry="118" fill="none" stroke="#B8860B" stroke-width="0.8" opacity="0.4"/>
  <ellipse cx="340" cy="210" rx="88" ry="85" fill="#C8842A"/>
  <ellipse cx="340" cy="185" rx="80" ry="72" fill="#D4923A"/>
  <ellipse cx="310" cy="172" rx="26" ry="30" fill="#B87820"/>
  <ellipse cx="370" cy="172" rx="26" ry="30" fill="#B87820"/>
  <ellipse cx="310" cy="172" rx="20" ry="24" fill="#C8842A"/>
  <ellipse cx="370" cy="172" rx="20" ry="24" fill="#C8842A"/>
  <ellipse cx="310" cy="175" rx="13" ry="15" fill="#1A0A04"/>
  <ellipse cx="370" cy="175" rx="13" ry="15" fill="#1A0A04"/>
  <ellipse cx="310" cy="175" rx="10" ry="12" fill="#0A0404"/>
  <ellipse cx="370" cy="175" rx="10" ry="12" fill="#0A0404"/>
  <ellipse cx="306" cy="171" rx="3" ry="3.5" fill="#F5E6C8" opacity="0.7"/>
  <ellipse cx="366" cy="171" rx="3" ry="3.5" fill="#F5E6C8" opacity="0.7"/>
  <ellipse cx="340" cy="210" rx="28" ry="22" fill="#B87820"/>
  <ellipse cx="340" cy="213" rx="18" ry="14" fill="#3A1A08"/>
  <ellipse cx="340" cy="212" rx="12" ry="8" fill="#2A0E04"/>
  <path d="M322 228 Q340 242 358 228" stroke="#8B5A1A" stroke-width="2" fill="none" stroke-linecap="round"/>
  <path d="M280 155 Q270 130 265 115 Q278 122 288 140 Z" fill="#B87820"/>
  <path d="M400 155 Q410 130 415 115 Q402 122 392 140 Z" fill="#B87820"/>
  <circle cx="310" cy="192" r="22" fill="none" stroke="#F5E6C8" stroke-width="3.5"/>
  <circle cx="370" cy="192" r="22" fill="none" stroke="#F5E6C8" stroke-width="3.5"/>
  <line x1="332" y1="192" x2="348" y2="192" stroke="#F5E6C8" stroke-width="3.5" stroke-linecap="round"/>
  <line x1="242" y1="186" x2="288" y2="189" stroke="#F5E6C8" stroke-width="3.5" stroke-linecap="round"/>
  <line x1="392" y1="189" x2="438" y2="186" stroke="#F5E6C8" stroke-width="3.5" stroke-linecap="round"/>
  <line x1="200" y1="210" x2="290" y2="210" stroke="#B8860B" stroke-width="0.8" opacity="0.5"/>
  <line x1="390" y1="210" x2="480" y2="210" stroke="#B8860B" stroke-width="0.8" opacity="0.5"/>
  <circle cx="200" cy="210" r="2.5" fill="#B8860B" opacity="0.5"/>
  <circle cx="480" cy="210" r="2.5" fill="#B8860B" opacity="0.5"/>
  <text x="340" y="96" text-anchor="middle" font-family="Georgia, serif" font-size="13" fill="#B8860B" letter-spacing="4" opacity="0.8">- - -  المعدّل  - - -</text>
  <text x="340" y="332" text-anchor="middle" font-family="Georgia, serif" font-size="28" fill="#F5E6C8" font-weight="bold" letter-spacing="1">زعمى ندوبل</text>
  <text x="340" y="358" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="#B8860B" letter-spacing="5">ZA3MA  NDOUBEL</text>
  <line x1="120" y1="318" x2="240" y2="318" stroke="#B8860B" stroke-width="0.8" opacity="0.4"/>
  <line x1="440" y1="318" x2="560" y2="318" stroke="#B8860B" stroke-width="0.8" opacity="0.4"/>
  <circle cx="120" cy="318" r="2" fill="#B8860B" opacity="0.4"/>
  <circle cx="560" cy="318" r="2" fill="#B8860B" opacity="0.4"/>
</svg>
''';