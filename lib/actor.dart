class Actor {
  final String name;
  final int debutYear;
  final String birthday;
  final String company;
  final String musicals;
  final String picture1;
  final String picture2;
  final String picture3;

  Actor({
    required this.name,
    required this.debutYear,
    required this.birthday,
    required this.company,
    required this.musicals,
    required this.picture1,
    required this.picture2,
    required this.picture3
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'] as String,
      debutYear: json['debutYear'] as int,
      birthday: json['birthday'] as String,
      company: json['company'] as String,
      musicals: json['musicals'] as String,
      picture1: json['picture1'] as String,
      picture2: json['picture2'] as String,
      picture3: json['picture3'] as String
    );
  }
}