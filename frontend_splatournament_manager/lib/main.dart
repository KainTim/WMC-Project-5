import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/pages/home_page.dart';
import 'package:frontend_splatournament_manager/pages/login_page.dart';
import 'package:frontend_splatournament_manager/pages/settings_page.dart';
import 'package:frontend_splatournament_manager/providers/auth_provider.dart';
import 'package:frontend_splatournament_manager/state_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StateProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SplatournamentApp(),
    ),
  );
}

class SplatournamentApp extends StatelessWidget {
  const SplatournamentApp({super.key});
  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);
    return MaterialApp.router(
      title: 'Splatournament Manager',
      routerConfig: routes,
      themeMode: stateProvider.theme,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}
var routes = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: "/login", builder: (context, state) => const LoginPage()),
    GoRoute(path: "/", builder: (context, state) => HomePage(),routes: [
      GoRoute(path: "settings", builder: (context, state) => SettingsPage(),)
    ])
  ]
);