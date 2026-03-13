import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/providers/tournament_provider.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:frontend_splatournament_manager/widgets/available_tournament_list.dart';
import 'package:frontend_splatournament_manager/widgets/teams_list_widget.dart';
import 'package:frontend_splatournament_manager/widgets/my_tournaments_carousel.dart';
import 'package:frontend_splatournament_manager/pages/create_tournament_page.dart';
import 'package:frontend_splatournament_manager/pages/create_team_page.dart';
import 'package:frontend_splatournament_manager/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Turniere' : 'Teams'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                if (_selectedIndex == 0) {
                  final tournamentProvider = Provider.of<TournamentProvider>(
                    context,
                    listen: false,
                  );
                  await tournamentProvider.refreshAvailableTournaments();
                } else {
                  final teamProvider = Provider.of<TeamProvider>(
                    context,
                    listen: false,
                  );
                  await teamProvider.refreshTeams();
                }
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aktualisierung der ${_selectedIndex == 0 ? "Turniere" : "Teams"} fehlgeschlagen',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 1) {
                context.go("/settings");
              } else if (value == 2) {
                Provider.of<AuthProvider>(context, listen: false).logout();
                context.go('/login');
              }
            },
            offset: const Offset(0, 48),
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 1, child: Text('Profil')),
                const PopupMenuItem(
                  value: 2,
                  child: Text('Abmelden', style: TextStyle(color: Colors.red)),
                ),
              ];
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Tournaments View
          Column(
            children: [
              const MyTournamentsCarousel(),
              const Expanded(child: AvailableTournamentList()),
            ],
          ),
          // Teams View
          const TeamsListWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Turniere',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Teams'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateTournamentPage(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTeamPage()),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
