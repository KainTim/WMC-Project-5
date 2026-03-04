import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';

class TournamentDetailPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailPage({super.key, required this.tournament});

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  bool isShowingTeams = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tournament"),
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(180),
        elevation: 3,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isShowingTeams = !isShowingTeams;
              });
            },
            icon: Icon(Icons.group),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          DetailHeader(
            tournament: widget.tournament,
            onTeamsChipClicked: () {
              setState(() {
                isShowingTeams = !isShowingTeams;
              });
            },
          ),
          Builder(
            builder: (context) {
              // Demo Content
              if (isShowingTeams) {
                return Text("Teams");
              }
              return Text("Not Teams");
            },
          ),
        ],
      ),
    );
  }
}

class DetailHeader extends StatelessWidget {
  final Tournament tournament;
  final Function onTeamsChipClicked;

  const DetailHeader({
    super.key,
    required this.tournament,
    required this.onTeamsChipClicked,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.maxFinite,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.vertical(
            bottom: Radius.circular(8),
          ),
          color: Colors.red,
          image: DecorationImage(
            fit: BoxFit.cover,
            // Currently a demo image
            image: NetworkImage(
              "https://flutter.dev/assets/image_1.w635.f71cbb614cd16a40bfb87e128278227c.png",
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, 0, 0, 12),
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: [
            Row(
              children: [
                InputChip(
                  onPressed: () => onTeamsChipClicked(),
                  label: Text(
                    "${tournament.currentTeamAmount} out of ${tournament.maxTeamAmount} Teams",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
