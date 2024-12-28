class Musical {
  final String title;
  final String place;
  final String firstDate;
  final String lastDate;
  final int duration;
  final int ageLimit;
  final int minPrice;
  final int maxPrice;
  final String actors;
  final String map;
  final String url;
  final String thumbnail;

  Musical({
    required this.title,
    required this.place,
    required this.firstDate,
    required this.lastDate,
    required this.duration,
    required this.ageLimit,
    required this.minPrice,
    required this.maxPrice,
    required this.actors,
    required this.map,
    required this.url,
    required this.thumbnail,
  });

  factory Musical.fromJson(Map<String, dynamic> json) {
    return Musical(
      title: json['title'] as String,
      place: json['place'] as String,
      firstDate: json['firstDate'] as String,
      lastDate: json['lastDate'] as String,
      duration: json['duration'] as int,
      ageLimit: json['ageLimit'] as int,
      minPrice: json['minPrice'] as int,
      maxPrice: json['maxPrice'] as int,
      actors: json['actors'] as String,
      map: json['map'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
}