import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';

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
  var tab = 0;            // 동적 UI생성: 하단바의 홈, 샵인 경우 화면을 다르게 함
  var data = [];          // 서버에서 받은 데이터(글)를 저장
  var isVisible = 0;      // 하단바를 보이게/보이지 않게 하기 위한 상태

  getData() async {       // 서버에서 데이터를 받아옴(get)
    var result = await http.get(Uri.parse("https://codingapple1.github.io/app/data.json"));

    if (result.statusCode == 200) {
      var result2 = json.decode(result.body);
      setState(() {
        data = result2;     // get한 데이터들을 state에 저장
      });
    } else {
      print("잘못된 페이지입니다");
    }
  }

  @override
  void initState() {      // MyApp 위젯이 로드될 때 실행됨
    super.initState();
    getData();            // 처음 실행될 때 데이터를 get 요청
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
      body: [ Home(data: data, isVisible: isVisible), Text("샵페이지")][tab],
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
class Home extends StatefulWidget {
  Home({super.key, this.data, this.isVisible});

  final data;
  var isVisible;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var scroll = ScrollController();    // 스크롤 상태를 저장

  @override
  void initState() {                  // Home 위젯이 로드될 때 실행됨
    super.initState();
    scroll.addListener(() {           // 스크롤 상태가 변경될 때마다 실행됨
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {    // 스크롤 위치가 끝일 때
        getData();                    // 처음 실행될 때 데이터를 받아옴
      }
    });
  }

  getData() async{
    var result = await http.get(Uri.parse("https://codingapple1.github.io/app/more1.json"));
    var result2 = json.decode(result.body);
    setState(() {
      widget.data.add(result2);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty){
      return ListView.builder(itemCount: widget.data.length, controller: scroll, itemBuilder: (c, i){
        return Column(
          children: [
            Image.network(widget.data[i]["image"]),
            Container(
              margin: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("좋아요 ${widget.data[i]["likes"].toString()}", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(widget.data[i]["user"]),    // 글쓴이
                  Text(widget.data[i]["content"]), // 글내용
                ],
              ),
            ),
          ],
        );
      });
    } else {                                // data가 아직 안 들어왔을 때(도착하지 않았을 때)
      return Center(
        child: CircularProgressIndicator()
      );
    }
  }
}
