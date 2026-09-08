import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'providers/library_provider.dart';
import 'providers/store_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const AppShelfBootstrap());
}

class AppShelfBootstrap extends StatefulWidget {
  const AppShelfBootstrap({super.key});

  @override
  State<AppShelfBootstrap> createState() => _AppShelfBootstrapState();
}

class _AppShelfBootstrapState extends State<AppShelfBootstrap> {
  late final ApiClient _api = ApiClient();
  late final AuthProvider _auth = AuthProvider(_api);
  late final StoreProvider _store = StoreProvider(_api);
  late final LibraryProvider _library = LibraryProvider(_api);

  bool _ready = false;
  bool _splashDone = false;
  bool _onboardingDone = true;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  Future<void> _bootstrap() async {
    await ApiConfig.loadOverride();
    _onboardingDone = await OnboardingScreen.isDone();
    await Future.wait([
      _auth.bootstrap(),
      _store.load(),
      NotificationService.instance.init(),
    ]);
    if (_auth.isLoggedIn) {
      await _library.refresh(requireAuth: false);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _api),
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider.value(value: _store),
        ChangeNotifierProvider.value(value: _library),
      ],
      child: MaterialApp(
        title: 'رف التطبيقات',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: (!_ready || !_splashDone)
            ? const SplashScreen()
            : !_onboardingDone
                ? OnboardingScreen(
                    onDone: () => setState(() => _onboardingDone = true),
                  )
                : const ShellScreen(),
      ),
    );
  }
}
