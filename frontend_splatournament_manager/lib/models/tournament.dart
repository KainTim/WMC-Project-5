class Tournament {
  final int id;
  final String name;
  final String description;
  final int maxTeamsAmount;
  final int currentTeamAmount;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.maxTeamsAmount,
    required this.currentTeamAmount,
  });

  factory Tournament.fromJson(dynamic json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      maxTeamsAmount: json['maxTeamsAmount'],
      currentTeamAmount: json['currentTeamAmount'],
    );
  }
}
