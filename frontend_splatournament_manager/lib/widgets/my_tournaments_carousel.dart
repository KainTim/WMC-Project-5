import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/pages/tournament_detail_page.dart';
import 'package:provider/provider.dart';

class MyTournamentsCarousel extends StatefulWidget {
  const MyTournamentsCarousel({super.key});

  @override
  State<MyTournamentsCarousel> createState() => _MyTournamentsCarouselState();
}

class _MyTournamentsCarouselState extends State<MyTournamentsCarousel> {
  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: teamProvider.getMyTeamsTournaments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final tournaments = snapshot.data ?? [];
        
        if (tournaments.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'My Tournaments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 150,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  elevation: 4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text(
                          'No tournaments found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'My Tournaments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final tournament = Tournament.fromJson(tournaments[index]);
                  return _TournamentCard(tournament: tournament);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;

  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentDetailPage(tournament: tournament),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tournament.description,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    tournament.isRegistrationOpen 
                        ? Icons.check_circle 
                        : Icons.cancel,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tournament.isRegistrationOpen 
                        ? 'Registration Open' 
                        : 'Registration Closed',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '${tournament.currentTeamAmount}/${tournament.maxTeamAmount} teams',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
