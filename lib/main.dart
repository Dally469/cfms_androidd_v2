// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:cfms/config/app_config.dart';
import 'package:cfms/data/repositories/auth_repository.dart';
import 'package:cfms/data/repositories/language_repository.dart';
import 'package:cfms/logic/bloc/app_bloc_observer.dart';
import 'package:cfms/logic/bloc/auth/auth_bloc.dart';
import 'package:cfms/logic/bloc/language/language_bloc.dart';
import 'package:cfms/logic/bloc/theme/theme_bloc.dart';
import 'package:cfms/logic/bloc/update/update_bloc.dart';
import 'package:cfms/screens/admin/admin.dashboard.screen.dart';
import 'package:cfms/screens/login.screen.dart';
import 'package:cfms/screens/member/dashboard.screen.dart';
import 'package:cfms/screens/select.language.dart';
import 'package:cfms/utils/app.state.dart';
import 'package:cfms/utils/colors.dart';
import 'package:cfms/utils/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/update_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Initialize system settings and environment
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  HttpOverrides.global = MyHttpOverrides();

  // Load shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Initialize language settings
  String? selectedLanguage = prefs.getString('language') ?? 'en';
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: ['en', 'fr', 'sw', 'rw'],
  );

  // Load app state
  final AppState appState = await _loadAppState();

  // Initialize repositories
  final languageRepository = LanguageRepository(prefs: prefs);
  final authRepository = AuthRepository(prefs: prefs);
  final updateRepository = UpdateRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(
            languageRepository: languageRepository,
            initialLanguage: selectedLanguage,
          ),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: authRepository,
            isLoggedIn: appState.isLoggedIn,
            userData: appState.json,
          ),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<UpdateBloc>(
          create: (context) => UpdateBloc(
            updateRepository: updateRepository,
            currentVersion: appState.version,
            buildNumber: appState.buildNumber,
          ),
        ),
        
      ],
      child: LocalizedApp(
        delegate,
        MyApp(
          initialLanguage: selectedLanguage,
          showHome: appState.showHome,
        ),
      ),
    ),
  );
}

/// Load the application state with robust error handling
Future<AppState> _loadAppState() async {
  bool showHome = false;
  String json = 'no';
  bool isLoggedIn = false;
  String version = '1.0.0';
  String buildNumber = '1';

  try {
    final prefs = await SharedPreferences.getInstance();
    showHome = prefs.getBool('showHome') ?? false;
    json = prefs.getString('current_member') ?? "no";
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    prefs.setString("version", version);
    prefs.setString("buildNumber", buildNumber);
  } catch (e) {
    debugPrint("Warning: Failed to initialize SharedPreferences: $e");
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    prefs.setString("version", version);
    prefs.setString("buildNumber", buildNumber);
  } catch (e) {
    debugPrint("Warning: Failed to get package info: $e");
  }

  if (kDebugMode) {
    print("User data: $json");
    print("Login state: $isLoggedIn");
    print("App version: $version ($buildNumber)");
  }

  return AppState(
    showHome: showHome,
    json: json,
    isLoggedIn: isLoggedIn,
    version: version,
    buildNumber: buildNumber,
  );
}

class MyApp extends StatelessWidget {
  final String initialLanguage;
  final bool showHome;

  const MyApp({
    super.key,
    required this.initialLanguage,
    required this.showHome,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        // Change locale based on LanguageBloc state
        if (languageState is LanguageLoaded) {
          changeLocale(context, languageState.languageCode);
        }

        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return LocalizationProvider(
              state: LocalizationProvider.of(context).state,
              child: MaterialApp(
                title: AppConfig.appTitle,
                theme: themeState.themeData,
                debugShowCheckedModeBanner: false,
                home: _buildHomeScreen(context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    if (!showHome) {
      return const Splash();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Check user role for proper dashboard
          return state.isAdmin ? const AdminDashboard() : const Dashboard();
        } else {
          return const Login();
        }
      },
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Start update check
    context.read<UpdateBloc>().add(CheckForUpdate());

    // Load version from BLoC
    final updateState = context.read<UpdateBloc>().state;
    if (updateState is UpdateInitial) {
      debugPrint(
          "Current version: ${updateState.currentVersion} (${updateState.buildNumber})");
    }

    // Navigate after delay
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
          context, MyPageRoute(widget: const SelectLanguage())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/icons/logo.png",
                width: 180,
                height: 180,
                color: whiteColor,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
                child: Text(
                  "Church Financial Management System",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w500,
                    color: whiteColor,
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          bottom: 60,
          left: 80,
          right: 80,
          child: Center(
            child: SpinKitDoubleBounce(
              color: orangeColor,
            ),
          ),
        ),

        // Show version from BLoC
        BlocBuilder<UpdateBloc, UpdateState>(
          builder: (context, state) {
            return Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "v${state is UpdateInitial ? state.currentVersion : 'Loading...'}",
                  style: GoogleFonts.lato(
                    color: whiteColor,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
