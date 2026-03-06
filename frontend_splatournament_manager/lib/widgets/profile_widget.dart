import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final TextEditingController teamController = TextEditingController(
    text: 'Team Name',
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            SizedBox(
              height: 128,
              width: 128,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://i.postimg.cc/0jqKB6mS/Profile-Image.png",
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(provider.username??"Unknown User", style: TextStyle(fontSize: 36)),
            Container(
              margin: EdgeInsets.fromLTRB(48, 8, 48, 0),
              child: TextFormField(controller: teamController),
            ),
          ],
        );
      },
    );
  }
}
