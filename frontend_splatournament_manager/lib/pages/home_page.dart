import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/providers/tournament_provider.dart';
import 'package:frontend_splatournament_manager/widgets/available_tournament_list.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Splatournament"),
        actions: [
          IconButton(
            onPressed: () async {
              final tournamentProvider =
                  Provider.of<TournamentProvider>(context, listen: false);
              try {
                await tournamentProvider.refreshAvailableTournaments();
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to refresh tournaments')),
                );
              }
            },
            icon: Icon(Icons.refresh),
          ),
          PopupMenuButton(
            onSelected: (value) {
              context.go("/settings");
            },
            offset: Offset(0, 48),
            itemBuilder: (context) {
              return [PopupMenuItem(value: 1, child: Text("Settings"))];
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 12, 0, 24),
        child: Column(children: [Spacer(), AvailableTournamentList()]),
      ),
    );
  }
}
