class Match {
  final int id;
  final int tournamentId;
  final int round;
  final int matchNumber;
  final int? team1Id;
  final int? team2Id;
  final int? winnerId;

  Match({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.matchNumber,
    this.team1Id,
    this.team2Id,
    this.winnerId,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      tournamentId: json['tournamentId'],
      round: json['round'],
      matchNumber: json['matchNumber'],
      team1Id: json['team1Id'],
      team2Id: json['team2Id'],
      winnerId: json['winnerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'round': round,
      'matchNumber': matchNumber,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'winnerId': winnerId,
    };
  }

  bool get hasWinner => winnerId != null;
  bool get canBePlayed => team1Id != null && team2Id != null;
}
