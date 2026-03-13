import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        final username = provider.username ?? 'Unbekannter Benutzer';
        final avatarText = username.length >= 3
            ? username.substring(0, 3).toUpperCase()
            : username.toUpperCase();

        return Column(
          children: [
            SizedBox(
              height: 128,
              width: 128,
              child: CircleAvatar(
                child: Text(
                  avatarText,
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(username, style: TextStyle(fontSize: 36)),
          ],
        );
      },
    );
  }
}
