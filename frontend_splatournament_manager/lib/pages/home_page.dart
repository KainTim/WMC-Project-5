import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/widgets/available_tournament_list.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Splatournament"),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              context.go("/settings");
            },
            itemBuilder: (context) {
              return [PopupMenuItem(value: 1,child: Text("Settings"),)];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AvailableTournamentList(),
        ],
      )
    );
  }
}
