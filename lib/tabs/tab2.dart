import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../actor.dart';
import '../musical.dart';
import '../helpers.dart';

class Tab2 extends StatefulWidget {
  final List<Musical> musicals;
  final List<Actor> actors;

  const Tab2({super.key, required this.musicals, required this.actors});

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  List<String> savedActors = [];
  late SharedPreferences prefs;

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      savedActors = prefs.getStringList('savedActors') ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double itemWidth = 120;
    final crossAxisCount = ((screenWidth - 40) / itemWidth).floor();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // Enables smooth scrolling
        slivers: [
          const SliverAppBar(
            // toolbarHeight: 50.0,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
                background: Image(
              image: AssetImage('assets/images/slivers/sliver2.jpeg'),
              fit: BoxFit.cover,
            )),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(15),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // Dynamic number of items per row
                // crossAxisSpacing: 10, // Horizontal spacing between items
                // mainAxisSpacing: 20, // Vertical spacing between items
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final actor = widget.actors[index];
                  final isSaved =
                      savedActors.contains(actor.name); // Check if it's saved
                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: GestureDetector(
                          onTap: () => showActorDetails(
                            context: context,
                            actor: actor,
                            allMusicals: widget.musicals,
                            allActors: widget.actors,
                          ),
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
                                      prefs.setStringList('savedActors', savedActors);

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
                                    isSaved ? Icons.favorite : Icons.favorite_border,
                                    color: isSaved ? Colors.red : Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                childCount: widget.actors.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
