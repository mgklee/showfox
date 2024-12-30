class Actor {
  final String name;
  final String code;
  final int debutYear;
  final String debutWork;
  final String birthday;
  final String company;
  final List musicals;
  final String profilePicture;

  Actor({
    required this.name,
    required this.code,
    required this.debutYear,
    required this.debutWork,
    required this.birthday,
    required this.company,
    required this.musicals,
    required this.profilePicture,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'] as String,
      code: json['code'] as String,
      debutYear: json['debutYear'] as int,
      debutWork: json['debutWork'] as String,
      birthday: json['birthday'] as String,
      company: json['company'] as String,
      musicals: json['musicals'] as List,
      profilePicture: json['profilePicture'] as String,
    );
  }
}