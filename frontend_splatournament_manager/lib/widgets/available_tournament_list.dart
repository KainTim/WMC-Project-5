import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/pages/tournament_detail_page.dart';
import 'package:frontend_splatournament_manager/state_provider.dart';
import 'package:provider/provider.dart';

class AvailableTournamentList extends StatelessWidget {
  const AvailableTournamentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<StateProvider>(
        builder: (BuildContext context, StateProvider value, Widget? child) =>
            FutureBuilder(
              future: value.fetchAvailableTournaments(),
              builder: (context, snapshot) {
                if(snapshot.hasError){
                  return Center(child: Text('Error: ${snapshot.error}'));
                }else if(!snapshot.hasData){
                  return Center(child: CircularProgressIndicator());
                }
                var list = snapshot.data!;
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.abc),
                      title: Text(list[index].name),
                      subtitle: Text(list[index].description),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentDetailPage(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      ),
    );
  }
}
