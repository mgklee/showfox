import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../actor.dart';
import '../musical.dart';
import '../helpers.dart';

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

  Widget musicalListView(BuildContext context, List<Musical> musicals) {
    return SizedBox(
      height: 480,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Set the scrolling direction to horizontal
        physics: const BouncingScrollPhysics(), // Enables smooth scrolling
        itemCount: musicals.length,
        itemBuilder: (context, index) {
          final musical = musicals[index];
          final isSaved = savedMusicals.contains(musical.title); // Check if it's saved

          return SizedBox(
            width: 300, // Set a fixed width for each card
            child: Card(
              color: Colors.orangeAccent[100],
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => showMusicalDetails(
                          context: context,
                          musical: musical,
                          allMusicals: widget.musicals,
                          allActors: widget.actors,
                        ),
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
                                        width: 200,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'MD Pick! 요즘 뜨는 뮤지컬',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          musicalListView(
            context,
            [0, 1, 2, 3, 6].map((index) => widget.musicals[index]).toList()
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '공연기간이 얼마 남지 않았어요!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          musicalListView(
            context,
            [8, 7, 5, 4, 9].map((index) => widget.musicals[index]).toList()
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
