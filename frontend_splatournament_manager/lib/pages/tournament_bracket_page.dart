import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/match.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/providers/match_provider.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

class TournamentBracketPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentBracketPage({super.key, required this.tournament});

  @override
  State<TournamentBracketPage> createState() => _TournamentBracketPageState();
}

class _TournamentBracketPageState extends State<TournamentBracketPage> {
  int _bracketSize(int n) {
    if (n <= 2) return 2;
    if (n <= 4) return 4;
    return 8;
  }

  int _roundCount(int bracketSize) {
    if (bracketSize == 2) return 2;
    if (bracketSize == 4) return 3;
    return 4;
  }

  Future<void> _initializeBracket() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    try {
      await matchProvider.initializeBracket(widget.tournament.id);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turnierbaum erfolgreich initialisiert'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Initialisierung des Turnierbaums fehlgeschlagen: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showWinnerDialog(Match match, Team team1, Team team2) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sieger auswählen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(team1.name),
              onTap: () => Navigator.pop(context, team1.id),
            ),
            ListTile(
              title: Text(team2.name),
              onTap: () => Navigator.pop(context, team2.id),
            ),
          ],
        ),
        actions: [
          if (match.hasWinner)
            TextButton(
              onPressed: () => Navigator.pop(context, -1), // Reset signal
              child: const Text('Zurücksetzen'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      try {
        if (result == -1) {
          await matchProvider.resetMatch(match.id);
        } else {
          await matchProvider.setMatchWinner(match.id, result);
        }
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result == -1
                    ? 'Match zurückgesetzt'
                    : 'Sieger erfolgreich festgelegt',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fehler: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.tournament.name)),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          teamProvider.getTeamsByTournament(widget.tournament.id),
          matchProvider.getMatchesByTournament(widget.tournament.id),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Fehler: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
              ),
            );
          }

          final teams = snapshot.data![0] as List<Team>;
          final matches = snapshot.data![1] as List<Match>;

          // Check if bracket is initialized
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Der Turnierbaum wurde noch nicht initialisiert',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: teams.length >= widget.tournament.maxTeamAmount
                        ? _initializeBracket
                        : null,
                    child: const Text('Turnierbaum initialisieren'),
                  ),
                  if (teams.length < widget.tournament.maxTeamAmount)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${teams.length}/${widget.tournament.maxTeamAmount} Teams angemeldet',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            );
          }

          final bracketSize = _bracketSize(teams.length);
          final roundCount = _roundCount(bracketSize);

          // Create a map of team IDs to Team objects for easy lookup
          final teamMap = {for (var team in teams) team.id: team};

          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _BracketBoard(
                  matches: matches,
                  teamMap: teamMap,
                  bracketSize: bracketSize,
                  roundCount: roundCount,
                  onMatchTap: _showWinnerDialog,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BracketBoard extends StatelessWidget {
  final List<Match> matches;
  final Map<int, Team> teamMap;
  final int bracketSize;
  final int roundCount;
  final Function(Match, Team, Team) onMatchTap;

  static const double _cardWidth = 112;
  static const double _cardHeight = 96;
  static const double _baseSlotHeight = 128;
  static const double _connectorWidth = 48;
  static const double _headerHeight = 28;
  static const double _lineThickness = 2;

  const _BracketBoard({
    required this.matches,
    required this.teamMap,
    required this.bracketSize,
    required this.roundCount,
    required this.onMatchTap,
  });

  String _roundLabel(int round) {
    if (round == roundCount - 1) return 'Sieger';
    final teamsInRound = bracketSize ~/ (1 << round);
    if (teamsInRound == 2) return 'Finale';
    if (teamsInRound == 4) return 'Halbfinale';
    return 'Viertelfinale';
  }

  double _cardTop(int round, int index) {
    final slotHeight = _baseSlotHeight * (1 << round).toDouble();
    return _headerHeight + index * slotHeight + (slotHeight - _cardHeight) / 2;
  }

  double _cardCenterY(int round, int index) =>
      _cardTop(round, index) + _cardHeight / 2;

  Match? _findMatch(int round, int matchNumber) {
    try {
      return matches.firstWhere(
        (m) => m.round == round && m.matchNumber == matchNumber,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineColor = colorScheme.outlineVariant;

    final boardWidth =
        roundCount * _cardWidth + (roundCount - 1) * _connectorWidth;
    final boardHeight = _headerHeight + bracketSize * _baseSlotHeight;

    final children = <Widget>[];

    // Build bracket
    for (int round = 0; round < roundCount; round++) {
      final cardsInRound = bracketSize ~/ (1 << round);
      final left = round * (_cardWidth + _connectorWidth);

      // Round label
      children.add(
        Positioned(
          left: left,
          top: 0,
          width: _cardWidth,
          height: _headerHeight,
          child: Center(
            child: Text(
              _roundLabel(round),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      );

      // Match cards
      for (int i = 0; i < cardsInRound; i++) {
        final match = _findMatch(round, i);

        children.add(
          Positioned(
            left: left,
            top: _cardTop(round, i),
            width: _cardWidth,
            height: _cardHeight,
            child: _MatchCard(
              match: match,
              teamMap: teamMap,
              onTap: match != null && match.canBePlayed && !match.hasWinner
                  ? () {
                      final team1 = teamMap[match.team1Id];
                      final team2 = teamMap[match.team2Id];
                      if (team1 != null && team2 != null) {
                        onMatchTap(match, team1, team2);
                      }
                    }
                  : match != null && match.hasWinner
                  ? () {
                      final team1 = teamMap[match.team1Id];
                      final team2 = teamMap[match.team2Id];
                      if (team1 != null && team2 != null) {
                        onMatchTap(match, team1, team2);
                      }
                    }
                  : null,
            ),
          ),
        );
      }

      // Draw connectors
      if (round == roundCount - 1) continue;

      final connectorLeft = left + _cardWidth;
      final matches = cardsInRound ~/ 2;
      final halfConnector = _connectorWidth / 2;

      for (int i = 0; i < matches; i++) {
        final yTop = _cardCenterY(round, i * 2);
        final yBottom = _cardCenterY(round, i * 2 + 1);
        final yMiddle = (yTop + yBottom) / 2;

        // Top horizontal line
        children.add(
          Positioned(
            left: connectorLeft,
            top: yTop - _lineThickness / 2,
            width: halfConnector,
            height: _lineThickness,
            child: DecoratedBox(decoration: BoxDecoration(color: lineColor)),
          ),
        );

        // Bottom horizontal line
        children.add(
          Positioned(
            left: connectorLeft,
            top: yBottom - _lineThickness / 2,
            width: halfConnector,
            height: _lineThickness,
            child: DecoratedBox(decoration: BoxDecoration(color: lineColor)),
          ),
        );

        // Vertical line
        children.add(
          Positioned(
            left: connectorLeft + halfConnector - _lineThickness / 2,
            top: yTop,
            width: _lineThickness,
            height: yBottom - yTop,
            child: DecoratedBox(decoration: BoxDecoration(color: lineColor)),
          ),
        );

        // Middle horizontal line to next round
        children.add(
          Positioned(
            left: connectorLeft + halfConnector,
            top: yMiddle - _lineThickness / 2,
            width: halfConnector,
            height: _lineThickness,
            child: DecoratedBox(decoration: BoxDecoration(color: lineColor)),
          ),
        );
      }
    }

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Stack(children: children),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Match? match;
  final Map<int, Team> teamMap;
  final VoidCallback? onTap;

  const _MatchCard({this.match, required this.teamMap, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (match == null) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
      );
    }

    final team1 = match!.team1Id != null ? teamMap[match!.team1Id] : null;
    final team2 = match!.team2Id != null ? teamMap[match!.team2Id] : null;
    final winner = match!.winnerId != null ? teamMap[match!.winnerId] : null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: match!.hasWinner ? 3 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: match!.hasWinner
              ? BorderSide(color: colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (team1 != null && team2 != null) ...[
                _TeamLabel(
                  team: team1,
                  isWinner: match!.winnerId == team1.id,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 4),
                Text(
                  'vs.',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                _TeamLabel(
                  team: team2,
                  isWinner: match!.winnerId == team2.id,
                  colorScheme: colorScheme,
                ),
              ] else if (winner != null) ...[
                _TeamLabel(
                  team: winner,
                  isWinner: true,
                  colorScheme: colorScheme,
                ),
              ] else
                Text(
                  '?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamLabel extends StatelessWidget {
  final Team team;
  final bool isWinner;
  final ColorScheme colorScheme;

  const _TeamLabel({
    required this.team,
    required this.isWinner,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      team.name,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
        color: isWinner ? colorScheme.primary : colorScheme.onSurface,
      ),
    );
  }
}
