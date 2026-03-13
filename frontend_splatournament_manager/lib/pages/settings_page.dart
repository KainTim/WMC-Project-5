import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/widgets/my_teams_widget.dart';
import 'package:frontend_splatournament_manager/widgets/theme_selector_widget.dart';

import '../widgets/profile_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const ProfileWidget(),
          ThemeSelectorWidget(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Meine Teams',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Expanded(child: MyTeamsWidget()),
        ],
      ),
    );
  }
}
