import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/widgets/theme_selector_widget.dart';
import 'package:provider/provider.dart';
import 'package:frontend_splatournament_manager/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(title: Text("Splatournament")),
      body: Column(
        children: [
          SizedBox(height: 24),
          ProfileWidget(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeSelectorWidget(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  context.go('/login');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
