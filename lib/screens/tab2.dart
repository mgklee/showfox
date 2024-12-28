import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../actor.dart';

// class Tab2 extends StatelessWidget {
//   final List<Map<String, String>> profiles = [
//     {
//       'name': '김소현',
//       'debut': '2001년',
//       'birthday': '1975.11.11',
//       'agency': '팜트리아일랜드',
//       'works': '명성황후',
//       'image': 'assets/images/kimsohyun.jpeg',
//     },
//     {
//       'name': '박은태',
//       'debut': '2007년',
//       'birthday': '1981.06.14',
//       'agency': '떼아뜨로',
//       'works': '웃는남자',
//       'image': 'assets/images/parkeuntae.jpeg',
//     },
//     // ... 추가 프로필
//   ];
//
//   final List<List<String>> actorImages = [
//     [
//       "assets/images/kimsohyun1.jpeg",
//       "assets/images/kimsohyun2.jpeg",
//       "assets/images/kimsohyun3.jpeg",
//     ],
//     [
//       "assets/images/parkeuntae1.jpeg",
//       "assets/images/parkeuntae2.jpeg",
//       "assets/images/parkeuntae3.jpeg",
//     ],
//     // ... 추가 이미지
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: profiles.length,
//       itemBuilder: (context, index) {
//         final profile = profiles[index];
//         final images = actorImages[index]; // 배우별 이미지 리스트 가져오기
//         return buildProfileCard(profile, images);
//       },
//     );
//   }
//
//   Widget buildProfileCard(Map<String, String> profile, List<String> images) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       padding: EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.orangeAccent, width: 3),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '${profile['name']}',
//             style: TextStyle(
//                 color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8.0),
//           CarouselSlider(
//             items: images.map((imagePath) {
//               return ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.asset(
//                   imagePath,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 ),
//               );
//             }).toList(),
//             options: CarouselOptions(
//               height: 200, // 슬라이더 높이
//               enlargeCenterPage: true,
//               enableInfiniteScroll: true,
//               autoPlay: true,
//             ),
//           ),
//           SizedBox(height: 16.0),
//           Text(
//             '데뷔년도: ${profile['debut']}',
//             style: TextStyle(color: Colors.black, fontSize: 15),
//           ),
//           SizedBox(height: 8.0),
//           Text(
//             '생년월일: ${profile['birthday']}',
//             style: TextStyle(color: Colors.black, fontSize: 15),
//           ),
//           SizedBox(height: 8.0),
//           Text(
//             '소속사: ${profile['agency']}',
//             style: TextStyle(color: Colors.black, fontSize: 15),
//           ),
//           SizedBox(height: 8.0),
//           Text(
//             '출연작: ${profile['works']}',
//             style: TextStyle(color: Colors.black, fontSize: 15),
//           ),
//         ],
//       ),
//     );
//   }
// }

class Tab2 extends StatefulWidget {
  const Tab2({Key? key}) : super(key: key);

  @override
  _ActorTabState createState() => _ActorTabState();
}

class _ActorTabState extends State<Tab2> {
  late Future<List<Actor>> actors;

  Future<List<Actor>> loadActorData() async {
    final String response = await rootBundle.loadString('assets/actor.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => Actor.fromJson(item as Map<String, dynamic>)).toList();
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

  void _showActorDetails(BuildContext context, Actor actor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "${actor.name} 상세정보",
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                actor.picture2,
                height: 300, // Fixed height for the image
                fit: BoxFit.fitHeight,
              ),
              const SizedBox(height: 10),
              _buildDetailRow("데뷔", "${actor.debutYear}년"),
              _buildDetailRow("생년월일", actor.birthday),
              _buildDetailRow("소속사", actor.company),
              _buildDetailRow("작품", actor.musicals),
            ],
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
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of items in a row
              crossAxisSpacing: 10.0, // Horizontal spacing between items
              mainAxisSpacing: 10.0, // Vertical spacing between items
            ),
            itemCount: actorList.length,
            itemBuilder: (context, index) {
              final actor = actorList[index];

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
                            actor.picture1,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Positioned(
                        //   top: 8,
                        //   right: 0,
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       setState(() {
                        //         if (isSaved) {
                        //           savedActors.remove(actor.title);
                        //         } else {
                        //           savedActors.add(actor.title);
                        //         }
                        //
                        //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        //         ScaffoldMessenger.of(context).showSnackBar(
                        //           SnackBar(
                        //             width: 300,
                        //             content: Text(isSaved ? '저장됨' : '저장 해제됨'),
                        //             duration: const Duration(seconds: 1), // Short duration for quick response
                        //             behavior: SnackBarBehavior.floating, // Makes it appear above other content
                        //             shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(8),
                        //             ),
                        //           ),
                        //         );
                        //       });
                        //     },
                        //     child: Icon(
                        //       isSaved ? Icons.bookmark : Icons.bookmark_border,
                        //       color: isSaved ? Colors.red : Colors.grey,
                        //       size: 28,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    actor.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              );
            },
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
