import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/pages/tournament_detail_page.dart';

class AvailableTournamentList extends StatelessWidget {
  const AvailableTournamentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.abc),
            title: Text("TITLE"),
            subtitle: Text("Description"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentDetailPage(),));
            },
          );
        },
      ),
    );
  }
}
