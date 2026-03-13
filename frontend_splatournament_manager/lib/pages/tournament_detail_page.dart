import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/pages/tournament_bracket_page.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:frontend_splatournament_manager/providers/tournament_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final DateFormat _tournamentDateFormat = DateFormat('dd.MM.yyyy', 'de_DE');

String _formatTournamentDate(String value) {
  return _tournamentDateFormat.format(DateTime.parse(value));
}

class TournamentDetailPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailPage({super.key, required this.tournament});

  @override
  State<TournamentDetailPage> createState() => _TournamentDetailPageState();
}

class _TournamentDetailPageState extends State<TournamentDetailPage> {
  bool isShowingTeams = false;

  void _showJoinTeamDialog(BuildContext context, int tournamentId) async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    try {
      final teams = await teamProvider.getUserTeams();

      if (!context.mounted) return;

      if (teams.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Du bist in keinem Team. Tritt zuerst einem Team bei oder erstelle eines.',
            ),
          ),
        );
        return;
      }

      final selectedTeam = await showDialog<Team>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Team auswählen'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(team.tag)),
                    title: Text(team.name),
                    subtitle: team.description.isNotEmpty
                        ? Text(team.description)
                        : null,
                    onTap: () => Navigator.pop(dialogContext, team),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Abbrechen'),
              ),
            ],
          );
        },
      );

      if (selectedTeam != null && context.mounted) {
        try {
          await teamProvider.registerTeamForTournament(
            tournamentId,
            selectedTeam.id,
          );

          if (!context.mounted) return;
          await Provider.of<TournamentProvider>(
            context,
            listen: false,
          ).refreshAvailableTournaments();

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${selectedTeam.name} wurde für das Turnier angemeldet.',
              ),
            ),
          );

          // Refresh teams list if currently showing
          if (isShowingTeams) {
            setState(() {});
          }
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Anmeldung fehlgeschlagen: ${e.toString().replaceAll('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Deine Teams konnten nicht geladen werden: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appBarBackground = colorScheme.surface.withValues(alpha: 0.78);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackground,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          widget.tournament.name,
          style: TextStyle(overflow: TextOverflow.ellipsis),
        ),
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
                onPressed: widget.tournament.isRegistrationOpen
                    ? () => _showJoinTeamDialog(context, widget.tournament.id)
                    : null,
                child: Text(
                  widget.tournament.isRegistrationFuture
                      ? 'Anmeldung noch nicht geöffnet'
                      : widget.tournament.isRegistrationPast
                      ? 'Anmeldung geschlossen'
                      : 'Mit Team anmelden',
                ),
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
              'Angemeldete Teams',
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
                  return Center(
                    child: Text(
                      'Fehler: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                    ),
                  );
                }
                final teams = snapshot.data ?? [];
                if (teams.isEmpty) {
                  return const Center(
                    child: Text('Noch keine Teams angemeldet.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(team.tag)),
                        title: Text(team.name),
                        subtitle: team.description.isNotEmpty
                            ? Text(team.description)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(
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
                                  content: Text(
                                    'Team konnte nicht entfernt werden: ${e.toString().replaceFirst('Exception: ', '')}',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
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
    final registrationPeriod =
        '${_formatTournamentDate(tournament.registrationStartDate)} - ${_formatTournamentDate(tournament.registrationEndDate)}';

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
                      'Anmeldezeitraum',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    Text(registrationPeriod),
                    SizedBox(height: 24),
                    Text(
                      'Format',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const Text('Einfaches K.-o.-System'),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TournamentBracketPage(tournament: tournament),
                            ),
                          );
                        },
                        child: const Text('Turnierbaum ansehen'),
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
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 250,
      width: double.maxFinite,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadiusDirectional.vertical(
            bottom: Radius.circular(16),
          ),
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Icon(
              Icons.emoji_events,
              size: 116,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
            Spacer(),
            Row(
              children: [
                Consumer<TournamentProvider>(
                  builder: (context, value, child){
                    final currentTournament = value.availableTournaments.firstWhere((t) => t.id == tournament.id);
                    return InputChip(
                    onPressed: () => onTeamsChipClicked(),
                    label: Text(
                      '${currentTournament.currentTeamAmount} von ${currentTournament.maxTeamAmount} Teams',
                    ),
                    );
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
