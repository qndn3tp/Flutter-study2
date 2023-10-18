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
  var tab = 0;                // 동적 UI생성: 하단바의 홈, 샵인 경우 화면을 다르게 함
  var data = [];              // 서버에서 받은 데이터(글)를 저장
  var isVisible = true;       // 하단바를 보이게/보이지 않게 하기 위한 상태

  getData() async {           // 서버에서 데이터를 받아옴(get)
    var result = await http.get(Uri.parse("https://codingapple1.github.io/app/data.json"));

    if (result.statusCode == 200) {
      var result2 = json.decode(result.body);
      setState(() {
        data = result2;       // get한 데이터들을 state에 저장
      });
    } else {
      print("잘못된 페이지입니다");
    }
  }

  @override
  // MyApp 위젯이 로드될 때 실행됨
  void initState() {
    super.initState();
    getData();                // 처음 실행될 때 데이터를 get 요청
  }

  // 스크롤 방향 상태를 전달받는 콜백함수 (하단바를 숨기기위함)
  void updateVisibility(visible) {
    setState(() {
      isVisible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instagram"),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),        // 새 글 작성 버튼
            onPressed: (){
              Navigator.push(context,                  // 새 글 작성 페이지로 이동
              MaterialPageRoute(builder: (c) => Upload()));
              },
            iconSize: 30,
          )
        ],
      ),
      body: [ Home(data: data, isVisibleCallback: updateVisibility), Text("샵페이지")][tab],
      bottomNavigationBar: isVisible    // isVisible의 상태에 따라 하단바를 두거나 숨김
        ? BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i){                     // 유저의 선택에 따라 state가 변하도록
          setState(() {
            tab = i;
          });
          },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "샵"),
        ],
        )
          : null                        // 하단바를 숨김
    );
  }
}


// 글 위젯 (사진, 좋아요, 글쓴이, 내용)
class Home extends StatefulWidget {
  Home({super.key, this.data, this.isVisible, this.isVisibleCallback});

  final data;
  var isVisible;
  final isVisibleCallback;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var scroll = ScrollController();    // 스크롤 상태를 저장

  // 서버에서 데이터를 더 받아오는 함수
  getMore() async{
    var result = await http.get(Uri.parse("https://codingapple1.github.io/app/more1.json"));
    var result2 = json.decode(result.body);
    setState(() {
      widget.data.add(result2);       // 받아온 data를 기존 부모 위젯의 data에 추가
    });
  }

  @override
  // Home 위젯이 로드될 때 실행됨
  void initState() {
    super.initState();
    scroll.addListener(() {                                               // 스크롤 상태가 변경될 때마다 실행됨
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {    // 스크롤 위치가 끝일 때
        getMore();                                                        // 처음 실행될 때 데이터를 추가로 받아옴
      }
      if (scroll.position.userScrollDirection.toString() == "ScrollDirection.reverse") {  // 스크롤 내릴 때 하단바가 보이지 않도록 함
        widget.isVisibleCallback(false);                                  // 스크롤을 내릴 때 isVisibleCallback을 호출하여 하단바 숨김
      }
      else if (scroll.position.userScrollDirection.toString() == "ScrollDirection.forward") {
        widget.isVisibleCallback(true);                                   // 스크롤 방향이 다른 경우 isVisibleCallback을 호출하여 하단바 표시
      }
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

// 새 글 작성 위젯
class Upload extends StatelessWidget {
  const Upload({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("새 게시물", style: TextStyle(fontSize: 20),),
        leading: IconButton(
          onPressed: (){ Navigator.pop(context); },
          icon: Icon(Icons.close),
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          Text("이미지 업로드 화면"),
          IconButton(
              onPressed: (){ Navigator.pop(context); },
              icon: Icon(Icons.close),
          )
        ],
      ),
    );
  }
}
