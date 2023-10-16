import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
      MaterialApp(
        theme: style.theme,
        home: MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;          // 동적 UI생성: 하단바의 홈, 샵인 경우 화면을 다르게 함

  getData() async{  // 서버에서 데이터를 받아옴(get)
    var result = await http.get(Uri.parse("https://codingapple1.github.io/app/data.json"));
    var result2 = json.decode(result.body);
  }

  @override
  void initState() {    // MyApp 위젯이 로드될 때 실행됨
    super.initState();
    getData();          // 처음 실행될 때 데이터를 get 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instagram"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: (){},
            iconSize: 30,
          )
        ],
      ),
      body: [ Home(), Text("샵페이지")][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i){       // 유저의 선택에 따라 state가 변하도록
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "샵"),
        ],
      )
    );
  }
}

// 글 위젯 (사진, 좋아요, 글쓴이, 내용)
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(itemCount: 3, itemBuilder: (c, i){
      return Column(
        children: [
          Image.asset("assets/panda.jpeg"),
          Container(
            margin: EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("좋아요 100", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("글쓴이"),
                Text("글내용"),
              ],
            ),
          ),
        ],
      );
    });
  }
}