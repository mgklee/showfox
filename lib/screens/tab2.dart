import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../actor.dart';

class Tab2 extends StatefulWidget {
  const Tab2({Key? key}) : super(key: key);

  @override
  _ActorTabState createState() => _ActorTabState();
}

class _ActorTabState extends State<Tab2> {
  late Future<List<Actor>> actors;
  List<String> savedActors = [];
  late SharedPreferences prefs; // 초기화 가능하도록 변경

  Future<List<Actor>> loadActorData() async {
    final String response = await rootBundle.loadString('assets/actor.json');
    final List<dynamic> data = json.decode(response);
    return data
        .map((item) => Actor.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      savedActors = prefs.getStringList('savedActors') ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    actors = loadActorData();
    initSharedPreferences();
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

    final directory = 'assets/images/${actor.code}/';
    final imagePaths = assets
        .where((String imagePath) => imagePath.startsWith(directory))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int currentIndex = 0; // 다이얼로그 내부 상태 관리
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                "${actor.name} 상세정보",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // 80% of screen width
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imagePaths.asMap().entries.map((entry) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(
                                currentIndex == entry.key ? 1 : 0.5,
                              ),
                            ),
                          );
                        }).toList(),
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
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double itemWidth = 150;
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

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // const SliverAppBar(
              //   pinned: false,
              //   expandedHeight: 100.0,
              //   flexibleSpace: FlexibleSpaceBar(
              //     background: Image(
              //       image: AssetImage('assets/images/sliver.png'),
              //       fit: BoxFit.cover,
              //     ),
              //     title: Text(\\
              //     ),
              //   ),
              // ),
              SliverPadding(
                padding: const EdgeInsets.all(30),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // 한 줄에 표시할 항목 수
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 30,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final actor = actorList[index];
                      final isSaved = savedActors.contains(actor.name);

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
                                        prefs.setStringList(
                                            'savedActors', savedActors);
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          width: 300,
                                          content:
                                              Text(isSaved ? '저장 해제됨' : '저장됨'),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
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
                    childCount: actorList.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
