import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/state_provider.dart';
import 'package:provider/provider.dart';

class TournamentDetailPage extends StatelessWidget {
  final int tournamentId;
  const TournamentDetailPage({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tournament"),),
      body: Consumer<StateProvider>(builder: (BuildContext context, StateProvider value, Widget? child) {
        var tournament = value.availableTournaments.where((x) => x.id == tournamentId).firstOrNull;
        if(tournament == null){
          return Center(child: Text("Tournament not found!"));
        }
        return Text("${tournament.maxTeamAmount}");
      },)
    );
  }

}