class Musical {
  final String title;
  final String thumbnail;
  final String place;
  final String map;
  final String firstDate;
  final String lastDate;
  final String duration;
  final String ageLimit;
  final String url;

  Musical({
    required this.title,
    required this.thumbnail,
    required this.place,
    required this.map,
    required this.firstDate,
    required this.lastDate,
    required this.duration,
    required this.ageLimit,
    required this.url,
  });

  factory Musical.fromJson(Map<String, dynamic> json) {
    return Musical(
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String,
      place: json['place'] as String,
      map: json['map'] as String,
      firstDate: json['firstDate'] as String,
      lastDate: json['lastDate'] as String,
      duration: json['duration'] as String,
      ageLimit: json['ageLimit'] as String,
      url: json['url'] as String,
    );
  }
}