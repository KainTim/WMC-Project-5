import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

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
              if (isShowingTeams) {
                return TournamentTeamsWidget(tournament: widget.tournament);
              }
              return TournamentContentWidget(tournament: widget.tournament);
            },
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: ElevatedButton(
                child: Text("Enter"),
                onPressed: () {
                  //TODO: Backend Call
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("tournament entered")));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentTeamsWidget extends StatefulWidget {
  final Tournament tournament;

  const TournamentTeamsWidget({super.key, required this.tournament});

  @override
  State<TournamentTeamsWidget> createState() => _TournamentTeamsWidgetState();
}

class _TournamentTeamsWidgetState extends State<TournamentTeamsWidget> {
  late Future<List<Team>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = Provider.of<TeamProvider>(
      context,
      listen: false,
    ).getTeamsByTournament(widget.tournament.id);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Registered Teams',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Team>>(
              future: _teamsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final teams = snapshot.data ?? [];
                if (teams.isEmpty) {
                  return Center(child: Text('No teams registered yet.'));
                }
                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(team.tag)),
                      title: Text(team.name),
                      subtitle: team.description.isNotEmpty
                          ? Text(team.description)
                          : null,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            await Provider.of<TeamProvider>(
                              context,
                              listen: false,
                            ).removeTeamFromTournament(
                              widget.tournament.id,
                              team.id,
                            );
                            setState(() {
                              _teamsFuture = Provider.of<TeamProvider>(
                                context,
                                listen: false,
                              ).getTeamsByTournament(widget.tournament.id);
                            });
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to remove team: $e'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentContentWidget extends StatelessWidget {
  final Tournament tournament;

  const TournamentContentWidget({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 12),
          Center(
            child: Text(tournament.description, style: TextStyle(fontSize: 17)),
          ),
          SizedBox(height: 12),
          Card.filled(
            child: SizedBox(
              width: double.infinity,
              height: 225,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Registration Period",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "${tournament.registrationStartDate} - ${tournament.registrationEndDate}",
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Format",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    Text("Single Elimination"),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          //TODO: Redirect to Ongoing View
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("ongoing clicked")),
                          );
                        },
                        child: Text("View ongoing"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          image: DecorationImage(
            fit: BoxFit.cover,
            //TODO: Replace with proper image
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
