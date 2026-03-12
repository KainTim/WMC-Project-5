import 'package:flutter/material.dart';
import 'package:frontend_splatournament_manager/models/team.dart';
import 'package:frontend_splatournament_manager/models/tournament.dart';
import 'package:frontend_splatournament_manager/providers/team_provider.dart';
import 'package:provider/provider.dart';

class TournamentBracketPage extends StatelessWidget {
  final Tournament tournament;

  const TournamentBracketPage({super.key, required this.tournament});

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

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(tournament.name)),
      body: FutureBuilder<List<Team>>(
        future: teamProvider.getTeamsByTournament(tournament.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final teams = snapshot.data ?? [];
          final bracketSize = _bracketSize(tournament.maxTeamAmount);
          final roundCount = _roundCount(bracketSize);

          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _BracketBoard(
                  teams: teams,
                  bracketSize: bracketSize,
                  roundCount: roundCount,
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
  final List<Team> teams;
  final int bracketSize;
  final int roundCount;

  static const double _cardWidth = 112;
  static const double _cardHeight = 96;
  static const double _baseSlotHeight = 128;
  static const double _connectorWidth = 48;
  static const double _headerHeight = 28;
  static const double _lineThickness = 2;

  const _BracketBoard({
    required this.teams,
    required this.bracketSize,
    required this.roundCount,
  });

  String _roundLabel(int round) {
    if (round == roundCount - 1) return 'Winner';
    final teamsInRound = bracketSize ~/ (1 << round);
    if (teamsInRound == 2) return 'Final';
    if (teamsInRound == 4) return 'Semi-finals';
    return 'Quarter-finals';
  }

  double _cardTop(int round, int index) {
    final slotHeight = _baseSlotHeight * (1 << round).toDouble();
    return _headerHeight + index * slotHeight + (slotHeight - _cardHeight) / 2;
  }

  double _cardCenterY(int round, int index) =>
      _cardTop(round, index) + _cardHeight / 2;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineColor = colorScheme.outlineVariant;

    final boardWidth =
        roundCount * _cardWidth + (roundCount - 1) * _connectorWidth;
    final boardHeight = _headerHeight + bracketSize * _baseSlotHeight;

    final children = <Widget>[];

    for (int round = 0; round < roundCount; round++) {
      final cardsInRound = bracketSize ~/ (1 << round);
      final left = round * (_cardWidth + _connectorWidth);

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

      for (int i = 0; i < cardsInRound; i++) {
        final String? label = (round == 0 && i < teams.length)
            ? teams[i].name
            : null;
        children.add(
          Positioned(
            left: left,
            top: _cardTop(round, i),
            width: _cardWidth,
            height: _cardHeight,
            child: _TeamCard(label: label),
          ),
        );
      }

      if (round == roundCount - 1) {
        continue;
      }

      final connectorLeft = left + _cardWidth;
      final matches = cardsInRound ~/ 2;
      final halfConnector = _connectorWidth / 2;

      for (int i = 0; i < matches; i++) {
        final yTop = _cardCenterY(round, i * 2);
        final yBottom = _cardCenterY(round, i * 2 + 1);
        final yMiddle = (yTop + yBottom) / 2;

        children.add(
          Positioned(
            left: connectorLeft,
            top: yTop - _lineThickness / 2,
            width: halfConnector,
            height: _lineThickness,
            child: DecoratedBox(decoration: BoxDecoration(color: lineColor)),
          ),
        );

        children.add(
          Positioned(
            left: connectorLeft,
            top: yBottom - _lineThickness / 2,
            width: halfConnector,
            height: _lineThickness,
            child: DecoratedBox(decoration: BoxDecoration(color: lineColor)),
          ),
        );

        children.add(
          Positioned(
            left: connectorLeft + halfConnector - _lineThickness / 2,
            top: yTop,
            width: _lineThickness,
            height: yBottom - yTop,
            child: DecoratedBox(decoration: BoxDecoration(color: lineColor)),
          ),
        );

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

class _TeamCard extends StatelessWidget {
  final String? label;

  const _TeamCard({this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isTbd = label == null;

    return Card(
      elevation: isTbd ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            isTbd ? '?' : label!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isTbd ? FontWeight.w400 : FontWeight.w600,
              color: isTbd
                  ? colorScheme.onSurface.withValues(alpha: 0.38)
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
