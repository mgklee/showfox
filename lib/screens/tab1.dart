import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../musical.dart';

class Tab1 extends StatefulWidget {
  const Tab1({Key? key}) : super(key: key);

  @override
  _MusicalTabState createState() => _MusicalTabState();
}

class _MusicalTabState extends State<Tab1> {
  late Future<List<Musical>> musicals;
  final Set<String> savedMusicals = {}; // To store the saved musical titles

  Future<List<Musical>> loadMusicalData() async {
    final String response = await rootBundle.loadString('assets/musical.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => Musical.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  void initState() {
    super.initState();
    musicals = loadMusicalData();
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

  void _showMusicalDetails(BuildContext context, Musical musical) {
    final NumberFormat currencyFormat = NumberFormat("#,###");

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
              _buildDetailRow("장소", musical.place),
              _buildDetailRow("공연기간", "${musical.firstDate} ~ ${musical.lastDate}"),
              _buildDetailRow("공연시간", "${musical.duration}분 (인터미션 20분 포함)"),
              _buildDetailRow("관람연령", "${musical.ageLimit}세 이상 관람가능"),
              _buildDetailRow("가격", "${currencyFormat.format(musical.minPrice)} ~ ${currencyFormat.format(musical.maxPrice)}원"),
              _buildDetailRow("캐스팅", musical.actors),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Musical>>(
      future: musicals,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading musicals'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No musicals found'));
        }

        final musicalList = snapshot.data!;
        return ListView.builder(
          scrollDirection: Axis.horizontal, // Set the scrolling direction to horizontal
          physics: const BouncingScrollPhysics(), // Enables smooth scrolling
          itemCount: musicalList.length,
          itemBuilder: (context, index) {
            final musical = musicalList[index];
            final isSaved = savedMusicals.contains(musical.title); // Check if it's saved

            return SizedBox(
              width: 300, // Set a fixed width for each card
              child: Card(
                color: Colors.orangeAccent[100],
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showMusicalDetails(context, musical);
                            },
                            child: Stack(
                              children: [
                                Image.network(
                                  musical.thumbnail,
                                  fit: BoxFit.contain,
                                  height: 350, // Fixed height for the image
                                  width: double.infinity,
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

                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            width: 300,
                                            content: Text(isSaved ? '저장됨' : '저장 해제됨'),
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
                  ],
                ),
              ),
            );
          },
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
