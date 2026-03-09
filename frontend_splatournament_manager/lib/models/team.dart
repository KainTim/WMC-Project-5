class Team {
  final int id;
  final String name;
  final String tag;
  final String description;
  final String createdAt;

  Team({
    required this.id,
    required this.name,
    required this.tag,
    required this.description,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      name: json['name'] as String,
      tag: json['tag'] as String,
      description: (json['description'] as String?) ?? '',
      createdAt: (json['createdAt'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'description': description,
      'createdAt': createdAt,
    };
  }
}

