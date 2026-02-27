import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/homepage.dart';
import 'package:frontend_splatournament_manager/settings_page.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Splatournament Manager',
      routerConfig: routes,
    );
  }
}
var routes = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => Homepage(),routes: [
      GoRoute(path: "settings", builder: (context, state) => SettingsPage(),)
    ])
  ]
);