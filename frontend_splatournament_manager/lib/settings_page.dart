import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/widgets/theme_selector_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Splatournament")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [ThemeSelectorWidget()],
        ),
      ),
    );
  }
}
