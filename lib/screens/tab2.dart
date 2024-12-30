import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../actor.dart';

class Tab2 extends StatefulWidget {
  const Tab2({Key? key}) : super(key: key);

  @override
  _ActorTabState createState() => _ActorTabState();
}

class _ActorTabState extends State<Tab2> {
  late Future<List<Actor>> actors;
  final Set<String> savedActors = {}; // To store the saved actor names

  Future<List<Actor>> loadActorData() async {
      final String response = await rootBundle.loadString('assets/actor.json');
    final List<dynamic> data = json.decode(response);
    return data
        .map((item) => Actor.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    actors = loadActorData();
  }

  Widget _buildDetailRow(String label, String value) {
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
          child: Text(value),
        ),
      ],
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "${actor.name} 상세정보",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      height: 400,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow("생년월일", actor.birthday),
                  _buildDetailRow(
                      "데뷔", "${actor.debutYear}년 ${actor.debutWork}"),
                  _buildDetailRow("소속사", actor.company),
                  _buildDetailRow("작품", actor.musicals),
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
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Define the size of each item (including spacing)
    const double itemWidth = 150;

    // Calculate the number of items per row
    final crossAxisCount = ((screenWidth - 40) / itemWidth).floor();

    return FutureBuilder<List<Actor>>(
      future: actors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading actors'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No actors found'));
        }

        final actorList = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Dynamic number of items per row
              crossAxisSpacing: 10, // Horizontal spacing between items
              mainAxisSpacing: 30, // Vertical spacing between items
            ),
            itemCount: actorList.length,
            itemBuilder: (context, index) {
              final actor = actorList[index];
              final isSaved =
                  savedActors.contains(actor.name); // Check if it's saved

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showActorDetails(context, actor);
                    },
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Image.network(
                            actor.profilePicture,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSaved) {
                                  savedActors.remove(actor.name);
                                } else {
                                  savedActors.add(actor.name);
                                }

                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    width: 300,
                                    content: Text(isSaved ? '저장됨' : '저장 해제됨'),
                                    duration: const Duration(
                                        seconds:
                                            1), // Short duration for quick response
                                    behavior: SnackBarBehavior
                                        .floating, // Makes it appear above other content
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
                    actor.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
