import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/pages/tournament_detail_page.dart';
import 'package:frontend_splatournament_manager/state_provider.dart';
import 'package:provider/provider.dart';

class AvailableTournamentList extends StatelessWidget {
  const AvailableTournamentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        children: [
          Row(children: [Text("Available Tournaments")]),
          SizedBox(
            width: double.infinity,
            height: 350,
            child: Consumer<StateProvider>(
              builder:
                  (
                    BuildContext context,
                    StateProvider provider,
                    Widget? child,
                  ) => TournamentListFutureBuilder(provider: provider),
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentListFutureBuilder extends StatelessWidget {
  final StateProvider provider;

  const TournamentListFutureBuilder({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: provider.fetchAvailableTournaments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        var list = snapshot.data!;
        return ListView.builder(
          shrinkWrap: false,
          itemCount: list.length,
          itemBuilder: (context, index) {
            var tournament = list[index];
            return TournamentListItem(tournament: tournament);
          },
        );
      },
    );
  }
}

class TournamentListItem extends StatelessWidget {
  final Tournament tournament;

  const TournamentListItem({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Icon(Icons.abc),
      title: Text(tournament.name),
      subtitle: Text(tournament.description),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentDetailPage(tournament: tournament),
          ),
        );
      },
    );
  }
}

