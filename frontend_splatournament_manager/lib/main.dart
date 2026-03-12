import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/pages/home_page.dart';
import 'package:frontend_splatournament_manager/pages/login_page.dart';
import 'package:frontend_splatournament_manager/pages/settings_page.dart';
import 'package:frontend_splatournament_manager/providers/auth_provider.dart';
import 'package:frontend_splatournament_manager/providers/match_provider.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:frontend_splatournament_manager/providers/theme_provider.dart';
import 'package:frontend_splatournament_manager/providers/tournament_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
      ],
      child: const SplatournamentApp(),
    ),
  );
}

class SplatournamentApp extends StatelessWidget {
  static const String baseUrl = "http://10.0.2.2:3000";
  const SplatournamentApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'Splatournament Manager',
      routerConfig: routes,
      themeMode: themeProvider.themeMode,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
    );
  }
}

final routes = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    final isLoggedIn = authProvider.isLoggedIn;
    final isGoingToLogin = state.matchedLocation == '/login';
    // redirect to login
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }
    //already logged in
    if (isLoggedIn && isGoingToLogin) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(path: "/login", builder: (context, state) => const LoginPage()),
    GoRoute(
      path: "/",
      builder: (context, state) => HomePage(),
      routes: [
        GoRoute(path: "settings", builder: (context, state) => SettingsPage()),
      ],
    ),
  ],
);
