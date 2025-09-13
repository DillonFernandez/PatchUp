//
// Main entry point for PatchUp app.
// Handles locale, navigation, splash screen, and initial page logic.
//

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/appbar.dart';
import 'components/bottonnav.dart';
import 'localization/app_localizations.dart';
import 'pages/login.dart';
import 'pages/register.dart';

// App entry point
void main() {
  runApp(const MyApp());
}

// Main app widget: manages locale and navigation
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  // Loads saved locale from shared preferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_language');
    if (langCode != null && langCode.isNotEmpty) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  // Determines initial page based on user session
  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    if (email.isNotEmpty) {
      UserSession.email = email;
      return const NavigationExample();
    }
    return const SplashScreen();
  }

  // Sets and persists locale
  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', locale.languageCode);
  }

  // Builds MaterialApp with localization and navigation logic
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PatchUp',
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('en');
      },
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Pass setLocale to children for language change
            return InheritedLocale(setLocale: setLocale, child: snapshot.data!);
          }
          return const Scaffold(
            backgroundColor: Color(0xFF04274B),
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF04274B),
          selectionColor: const Color(0xFF04274B).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF04274B),
        ),
      ),
    );
  }
}

// Inherited widget to pass setLocale down the widget tree
class InheritedLocale extends InheritedWidget {
  final void Function(Locale) setLocale;

  const InheritedLocale({required this.setLocale, required Widget child})
    : super(child: child);

  static InheritedLocale? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedLocale>();

  @override
  bool updateShouldNotify(InheritedLocale oldWidget) => false;
}

// Splash screen for unauthenticated users
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF04274B),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout calculations for splash screen
          final h = constraints.maxHeight;
          final scale = (h / 720).clamp(0.78, 1.0);
          final heroMin = 200.0;
          final heroMax = 400.0;
          final heroBaseFrac = 0.43;
          final topHeight = (h * heroBaseFrac * scale).clamp(heroMin, heroMax);
          final headingFont = (32.0 * scale).clamp(24.0, 32.0);
          final subtitleFont = (18.0 * scale).clamp(13.0, 18.0);
          final buttonHeight = (56.0 * scale).clamp(44.0, 56.0);
          final outerVerticalPad = (28.0 * scale).clamp(16.0, 28.0);
          final innerCardPadH = (22.0 * scale).clamp(14.0, 22.0);
          final innerCardPadV = (28.0 * scale).clamp(18.0, 28.0);
          final gapHeadingTop = (10.0 * scale).clamp(6.0, 10.0);
          final gapAfterHeading = (18.0 * scale).clamp(10.0, 18.0);
          final gapBarTop = (28.0 * scale).clamp(16.0, 28.0);
          final gapBarBottom = (28.0 * scale).clamp(16.0, 28.0);
          final gapBetweenButtons = (16.0 * scale).clamp(10.0, 16.0);

          return Column(
            children: [
              // Logo area
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF04274B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                ),
                width: double.infinity,
                height: topHeight,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: (40.0 * scale).clamp(20, 40)),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 24 * scale,
                            offset: Offset(0, 8 * scale),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(32 * scale),
                      ),
                      child: Image.asset(
                        'assets/images/logo/Logo 2.webp',
                        width: 220 * scale,
                        height: 180 * scale,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // Lower card with heading, subtitle, and buttons
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 16 * scale),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 24,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24 * scale,
                        vertical: outerVerticalPad,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: EdgeInsets.symmetric(
                          horizontal: innerCardPadH,
                          vertical: innerCardPadV,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32 * scale),
                        ),
                        child: LayoutBuilder(
                          builder: (context, inner) {
                            return SizedBox(
                              height: inner.maxHeight,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(height: gapHeadingTop),
                                  // Heading
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      appLoc.translate('Fixing Roads Together'),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: headingFont,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF03264c),
                                        height: 1.1,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: gapAfterHeading),
                                  // Subtitle
                                  Text(
                                    appLoc.translate('Splash Subtitle'),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: subtitleFont,
                                      color: const Color(0xFFB1B5C3),
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: gapBarTop),
                                  Container(
                                    width: 48 * scale,
                                    height: 4 * scale,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF04274B,
                                      ).withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(
                                        4 * scale,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: gapBarBottom),
                                  // Login button
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const LoginPage(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF04274B,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * scale,
                                          ),
                                        ),
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12 * scale,
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          appLoc.translate('Login'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: (22.0 * scale).clamp(
                                              16.0,
                                              22.0,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: gapBetweenButtons),
                                  // Register button
                                  SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const RegisterPage(),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF04274B,
                                        ),
                                        side: BorderSide(
                                          color: const Color(0xFF04274B),
                                          width: 2 * scale,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15 * scale,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12 * scale,
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          appLoc.translate('Register'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: (22.0 * scale).clamp(
                                              16.0,
                                              22.0,
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
