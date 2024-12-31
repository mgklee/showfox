import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../musical.dart';
import '../actor.dart';

class Tab1 extends StatefulWidget {
  final List<Musical> musicals;
  final List<Actor> actors;

  const Tab1({super.key, required this.musicals, required this.actors});

  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  List<String> savedMusicals = [];
  late final SharedPreferences prefs;

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      savedMusicals = prefs.getStringList('savedMusicals') ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Widget _buildDetailRow(String label, value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: value,
        ),
      ],
    );
  }

  void _showMusicalDetails(BuildContext context, Musical musical) {
    final NumberFormat currencyFormat = NumberFormat("#,###");
    List<Widget> actors = [];

    for (int i = 0; i < musical.actors.length; i++) {
      Iterable<Actor> match = widget.actors.where(
        (element) => element.name == musical.actors[i]
      );

      if (match.isEmpty) {
        actors.add(Text(musical.actors[i]));
      } else {
        for (Actor actor in match) {
          actors.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _showActorDetails(context, actor);
              },
              child: Text(musical.actors[i]),
            ),
          );
        }
      }

      if (i+1 < musical.actors.length) {
        actors.add(const Text(", "));
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "${musical.title} 상세정보",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("장소", Text(musical.place)),
              _buildDetailRow("공연기간", Text("${musical.firstDate} ~ ${musical.lastDate}")),
              _buildDetailRow("공연시간", Text("${musical.duration}분 (인터미션 20분 포함)")),
              _buildDetailRow("관람연령", Text("${musical.ageLimit}세 이상 관람가능")),
              _buildDetailRow("가격", Text("${currencyFormat.format(musical.minPrice)} ~ ${currencyFormat.format(musical.maxPrice)}원")),
              _buildDetailRow("캐스팅", Wrap(children: actors)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('닫기'),
            ),
            TextButton(
              onPressed: () {
                _launchURL(musical.map);
                Navigator.of(context).pop();
              },
              child: const Text('지도 보기'),
            ),
            TextButton(
              onPressed: () {
                _launchURL(musical.url); // Open the musical's URL
                Navigator.of(context).pop();
              },
              child: const Text('예매하기'),
            ),
          ],
        );
      },
    );
  }

  void _showActorDetails(BuildContext context, Actor actor) async {
    AssetBundle bundle = DefaultAssetBundle.of(context);
    final assetManifest = await AssetManifest.loadFromAssetBundle(bundle);
    final assets = assetManifest.listAssets();

    // Format the directory name based on the actor's name
    final directory = 'assets/images/${actor.code}/';

    // Filter out images in the dynamically chosen directory
    final imagePaths = assets
        .where((String imagePath) => imagePath.startsWith(directory))
        .toList();

    List<Widget> musicals = [];

    for (int i = 0; i < actor.musicals.length; i++) {
      Iterable<Musical> match = widget.musicals.where(
              (element) => element.title == actor.musicals[i]
      );

      if (match.isEmpty) {
        musicals.add(Text(actor.musicals[i]));
      } else {
        for (Musical musical in match) {
          musicals.add(
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                _showMusicalDetails(context, musical);
              },
              child: Text(actor.musicals[i]),
            ),
          );
        }
      }

      if (i+1 < actor.musicals.length) {
        musicals.add(const Text(", "));
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int currentIndex = 0;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                "${actor.name} 상세정보",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CarouselSlider(
                            items: imagePaths.map((imagePath) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.height * 0.5,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                              autoPlay: true,
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: imagePaths.asMap().entries.map((entry) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(
                                      currentIndex == entry.key ? 1 : 0.5,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow("생년월일", Text(actor.birthday)),
                      _buildDetailRow("데뷔", Text("${actor.debutYear}년 ${actor.debutWork}")),
                      _buildDetailRow("소속사", Text(actor.company)),
                      _buildDetailRow("작품", Wrap(children: musicals)),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal, // Set the scrolling direction to horizontal
      physics: const BouncingScrollPhysics(), // Enables smooth scrolling
      itemCount: widget.musicals.length,
      itemBuilder: (context, index) {
        final musical = widget.musicals[index];
        final isSaved = savedMusicals.contains(musical.title); // Check if it's saved

        return SizedBox(
          width: 300, // Set a fixed width for each card
          child: Card(
            color: Colors.orangeAccent[100],
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showMusicalDetails(context, musical),
                      child: Stack(
                        children: [
                          Image.network(
                            musical.thumbnail,
                            width: double.infinity,
                            height: 350, // Fixed height for the image
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            top: 8,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSaved) {
                                    savedMusicals.remove(musical.title);
                                  } else {
                                    savedMusicals.add(musical.title);
                                  }
                                  prefs.setStringList('savedMusicals', savedMusicals);

                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      width: 300,
                                      content: Text(isSaved ? '저장 해제됨' : '저장됨'),
                                      duration: const Duration(seconds: 1), // Short duration for quick response
                                      behavior: SnackBarBehavior.floating, // Makes it appear above other content
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                });
                              },
                              child: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: isSaved ? Colors.red : Colors.grey,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      musical.title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      musical.place,
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text("${musical.firstDate} ~ ${musical.lastDate}"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
