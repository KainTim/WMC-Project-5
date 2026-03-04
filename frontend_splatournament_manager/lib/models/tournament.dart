class Tournament {
  final int id;
  final String name;
  final String description;
  final int maxTeamAmount;
  final int currentTeamAmount;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.maxTeamAmount,
    required this.currentTeamAmount,
  });

  factory Tournament.fromJson(dynamic json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      maxTeamAmount: json['maxTeamAmount'],
      currentTeamAmount: json['currentTeamAmount'],
    );
  }
}
