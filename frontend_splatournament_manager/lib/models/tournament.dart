class Tournament {
  final int id;
  final String name;
  final String description;
  final int maxTeamAmount;
  final int currentTeamAmount;
  final String registrationStartDate;
  final String registrationEndDate;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.maxTeamAmount,
    required this.currentTeamAmount,
    required this.registrationStartDate,
    required this.registrationEndDate,
  });

  factory Tournament.fromJson(dynamic json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      maxTeamAmount: json['maxTeamAmount'],
      currentTeamAmount: json['currentTeamAmount'],
      registrationStartDate: json['registrationStartDate'],
      registrationEndDate: json['registrationEndDate'],
    );
  }

  bool get isRegistrationOpen {
    final now = DateTime.now();
    final startDate = DateTime.parse(registrationStartDate);
    final endDate = DateTime.parse(registrationEndDate);
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isRegistrationPast {
    final now = DateTime.now();
    final endDate = DateTime.parse(registrationEndDate);
    return now.isAfter(endDate);
  }

  bool get isRegistrationFuture {
    final now = DateTime.now();
    final startDate = DateTime.parse(registrationStartDate);
    return now.isBefore(startDate);
  }
}
