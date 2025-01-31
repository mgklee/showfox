import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'musical.dart';
import 'actor.dart';

/// A reusable widget for building a detail row with a label and value.
Widget buildDetailRow(String label, Widget value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 60,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Flexible(child: value),
    ],
  );
}

/// Shows the details of a Musical in a dialog.
void showMusicalDetails({
  required BuildContext context,
  required Musical musical,
  required List<Musical> allMusicals,
  required List<Actor> allActors,
}) {
  final NumberFormat currencyFormat = NumberFormat("#,###");

  // Build a list of actor widgets, linking them to actor details
  List<Widget> actorWidgets = [];
  for (int i = 0; i < musical.actors.length; i++) {
    Iterable<Actor> match = allActors.where(
      (actor) => actor.name == musical.actors[i],
    );
    if (match.isEmpty) {
      actorWidgets.add(Text(musical.actors[i]));
    } else {
      for (Actor actor in match) {
        actorWidgets.add(
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              showActorDetails(
                context: context,
                actor: actor,
                allMusicals: allMusicals,  // We'll handle next section
                allActors: allActors,  // if showActorDetails also needs it
              );
            },
            child: Text(
              musical.actors[i],
              style: const TextStyle(color: Colors.deepPurple),
            ),
          ),
        );
      }
    }
    if (i + 1 < musical.actors.length) {
      actorWidgets.add(const Text(", "));
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "${musical.title} 상세정보",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDetailRow("장소", Text(musical.place)),
            buildDetailRow("공연기간", Text("${musical.firstDate} ~ ${musical.lastDate}")),
            buildDetailRow("공연시간", Text("${musical.duration}분 (인터미션 20분 포함)")),
            buildDetailRow("관람연령", Text("${musical.ageLimit}세 이상 관람가능")),
            buildDetailRow(
              "가격",
              Text(
                "${currencyFormat.format(musical.minPrice)} ~ "
                "${currencyFormat.format(musical.maxPrice)}원"
              ),
            ),
            buildDetailRow("캐스팅", Wrap(children: actorWidgets)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              launchExternalURL(musical.map);
              Navigator.of(context).pop();
            },
            child: const Text('지도 보기'),
          ),
          TextButton(
            onPressed: () {
              launchExternalURL(musical.url);
              Navigator.of(context).pop();
            },
            child: const Text('예매하기'),
          ),
        ],
      );
    },
  );
}

/// Shows the details of an Actor in a dialog.
Future<void> showActorDetails({
  required BuildContext context,
  required Actor actor,
  required List<Musical> allMusicals,
  required List<Actor> allActors, // if you also need to cross-link to actors
}) async {
  // Load assets for actor images
  AssetBundle bundle = DefaultAssetBundle.of(context);
  final assetManifest = await AssetManifest.loadFromAssetBundle(bundle);
  final assets = assetManifest.listAssets();
  final directory = 'assets/images/${actor.code}/';
  final imagePaths = assets
    .where((String path) => path.startsWith(directory))
    .toList();

  // Build a list of musicals the actor has performed in
  List<Widget> musicalWidgets = [];
  for (int i = 0; i < actor.musicals.length; i++) {
    Iterable<Musical> match = allMusicals.where(
      (musical) => musical.title == actor.musicals[i],
    );
    if (match.isEmpty) {
      musicalWidgets.add(Text(actor.musicals[i]));
    } else {
      for (Musical musical in match) {
        musicalWidgets.add(
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              showMusicalDetails(
                context: context,
                musical: musical,
                allMusicals: allMusicals,
                allActors: allActors,
              );
            },
            child: Text(
              actor.musicals[i],
              style: const TextStyle(color: Colors.deepPurple),
            ),
          ),
        );
      }
    }
    if (i + 1 < actor.musicals.length) {
      musicalWidgets.add(const Text(", "));
    }
  }

  // Display dialog with Actor details
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
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carousel of actor images
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
                            height: MediaQuery.of(context).size.height * 0.4,
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
                        // Dots indicator
                        Positioned(
                          bottom: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imagePaths.asMap().entries.map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(
                                    alpha: currentIndex == entry.key ? 1 : 0.5,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildDetailRow("생년월일", Text(actor.birthday)),
                    buildDetailRow("데뷔", Text("${actor.debutYear}년 ${actor.debutWork}")),
                    buildDetailRow("소속사", Text(actor.company)),
                    buildDetailRow("작품", Wrap(children: musicalWidgets)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

/// A helper function to launch URLs externally.
Future<void> launchExternalURL(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
