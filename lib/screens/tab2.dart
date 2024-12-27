import 'package:flutter/material.dart';

class Tab2 extends StatelessWidget {
  final List<Map<String, String>> profiles = [
    {
      'name': '김소현',
      'debut': '2001년',
      'birthday': '1975.11.11',
      'agency': '팜트리아일랜드',
      'works': '명성황후',
      'image': 'assets/images/kimsohyun.jpeg', // 파일명에 한글 안 됨
    },
    {
      'name': '박은태',
      'debut': '2007년',
      'birthday': '1981.06.14',
      'agency': '떼아뜨로',
      'works': '웃는남자',
      'image': 'assets/images/parkeuntae.jpeg',
    },
    {
      'name': '홍광호',
      'debut': '2002년',
      'birthday': '1982.04.06',
      'agency': 'PL엔터테인먼트',
      'works': '지킬앤하이드',
      'image': 'assets/images/hongkwangho.jpeg',
    },
    {
      'name': '김준수',
      'debut': '2004년',
      'birthday': '1987.01.01',
      'agency': '팜트리아일랜드',
      'works': '알라딘',
      'image': 'assets/images/kimjunsoo.jpeg',
    },
    {
      'name': '조형균',
      'debut': '2008년',
      'birthday': '1984.10.25',
      'agency': '㈜알앤디웍스',
      'works': '시라노',
      'image': 'assets/images/chohyungkyun.gif',
    },
    {
      'name': '유준상',
      'debut': '1995년',
      'birthday': '1969.11.28',
      'agency': '나무엑터스',
      'works': '스윙 데이즈_암호명 A',
      'image': 'assets/images/yoojunsang.jpeg',
    },
    {
      'name': '옥주현',
      'debut': '1998년',
      'birthday': '1980.03.20',
      'agency': '포트럭주식회사',
      'works': '마타하리',
      'image': 'assets/images/okjoohyun.gif',
    },
    {
      'name': '마이클 리',
      'debut': '1995년',
      'birthday': '1973.06.05',
      'agency': '블루스테이지',
      'works': '지저스 크라이스트 수퍼스타',
      'image': 'assets/images/michaellee.jpeg',
    },
    {
      'name': '윤도현',
      'debut': '1994년',
      'birthday': '1972.02.03',
      'agency': '디컴퍼니',
      'works': '광화문 연가',
      'image': 'assets/images/yoondohyun.jpeg',
    },
    {
      'name': '박진주',
      'debut': '2011년',
      'birthday': '1998.02.03',
      'agency': '프레인TPC',
      'works': '고스트 베이커리',
      'image': 'assets/images/parkjinjoo.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return buildProfileCard(profile);
      },
    );
  }

  Widget buildProfileCard(Map<String, String> profile) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.orangeAccent, width: 3),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: AssetImage(profile['image']!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${profile['name']}',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                SizedBox(height: 8.0),
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
          ),
        ],
      ),
    );
  }
}
