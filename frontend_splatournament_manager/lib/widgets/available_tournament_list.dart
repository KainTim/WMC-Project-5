import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/pages/tournament_detail_page.dart';
import 'package:frontend_splatournament_manager/providers/tournament_provider.dart';
import 'package:provider/provider.dart';

class AvailableTournamentList extends StatelessWidget {
  const AvailableTournamentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Verfügbare Turniere',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Consumer<TournamentProvider>(
            builder: (context, provider, _) {
              return TournamentListFutureBuilder(provider: provider);
            },
          ),
        ),
      ],
    );
  }
}

class TournamentListFutureBuilder extends StatelessWidget {
  final TournamentProvider provider;

  const TournamentListFutureBuilder({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tournament>>(
      future: provider.ensureTournamentsLoaded(),
      builder: (context, snapshot) {
        final list = provider.availableTournaments;
        if (snapshot.connectionState == ConnectionState.waiting &&
            list.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError && list.isEmpty) {
          return Center(
            child: Text(
              'Fehler: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
            ),
          );
        }

        if (list.isEmpty) {
          return const Center(child: Text('Keine Turniere gefunden'));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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

String _fmtDate(String iso) {
  try {
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  } catch (_) {
    return iso;
  }
}

class TournamentListItem extends StatelessWidget {
  final Tournament tournament;

  const TournamentListItem({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final dateRange =
        '${_fmtDate(tournament.registrationStartDate)} – ${_fmtDate(tournament.registrationEndDate)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TournamentDetailPage(tournament: tournament),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                child: const Icon(Icons.emoji_events),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tournament.currentTeamAmount}/${tournament.maxTeamAmount} Teams\n$dateRange',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
