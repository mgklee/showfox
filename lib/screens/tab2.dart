import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Tab2 extends StatelessWidget {
  final List<Map<String, String>> profiles = [
    {
      'name': '김소현',
      'debut': '2001년',
      'birthday': '1975.11.11',
      'agency': '팜트리아일랜드',
      'works': '명성황후',
      'image': 'assets/images/kimsohyun.jpeg',
    },
    {
      'name': '박은태',
      'debut': '2007년',
      'birthday': '1981.06.14',
      'agency': '떼아뜨로',
      'works': '웃는남자',
      'image': 'assets/images/parkeuntae.jpeg',
    },
    // ... 추가 프로필
  ];

  final List<List<String>> actorImages = [
    [
      "assets/images/kimsohyun1.jpeg",
      "assets/images/kimsohyun2.jpeg",
      "assets/images/kimsohyun3.jpeg",
    ],
    [
      "assets/images/parkeuntae1.jpeg",
      "assets/images/parkeuntae2.jpeg",
      "assets/images/parkeuntae3.jpeg",
    ],
    // ... 추가 이미지
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        final images = actorImages[index]; // 배우별 이미지 리스트 가져오기
        return buildProfileCard(profile, images);
      },
    );
  }

  Widget buildProfileCard(Map<String, String> profile, List<String> images) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orangeAccent, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${profile['name']}',
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          CarouselSlider(
            items: images.map((imagePath) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 200, // 슬라이더 높이
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              autoPlay: true,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            '데뷔년도: ${profile['debut']}',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          SizedBox(height: 8.0),
          Text(
            '생년월일: ${profile['birthday']}',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          SizedBox(height: 8.0),
          Text(
            '소속사: ${profile['agency']}',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          SizedBox(height: 8.0),
          Text(
            '출연작: ${profile['works']}',
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
