import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// 위젯
import './widgets/Upload.dart';
import './widgets/Home.dart';

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
  var userImage;              // 업로드 할 사진의 상태
  var userContent;            // 직접 업로드 할 글의 상태

  // 서버에서 데이터를 받아오는 함수(get)
  getData() async {
    var result = await http.get(Uri.parse("https://codingapple1.github.io/app/data.json"));

    if (result.statusCode == 200) {
      var result2 = json.decode(result.body);
      setState(() {
        data = result2;             // get한 데이터들을 state에 저장
      });
    } else {
      print("잘못된 페이지입니다");
    }
  }

  // 새 게시물의 text를 저장하는 함수
  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  // 서버의 data에 새 게시물(이미지+글)을 추가하는 함수
  addMyData(){
    var myData = {
      "id": data.length,
      "image": userImage,
      "likes": 0,
      "date": 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'Geonhye Kim',
    };
    setState(() {
      data.insert(0, myData);         // 서버의 data에 추가
    });
  }

  @override
  // MyApp 위젯이 로드될 때 실행되는 함수
  void initState() {
    super.initState();
    getData();                      // 처음 실행될 때 데이터를 get 요청
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
          IconButton(                                  // 새 글 작성 버튼
            icon: Icon(Icons.add_box_outlined),
            onPressed: () async {
              var picker = ImagePicker();              // 이미지를 가져옴
              var image = await picker.pickImage(source: ImageSource.gallery);    // 유저의 갤러리에 접근해 이미지를 가져옴
              if (image != null) {
                setState(() {
                  userImage = File(image.path);        // 유저가 선택한 이미지 경로를 저장
                });
              }
              // ignore: use_build_context_synchronously
              Navigator.push(context,                  // 새 글 작성 페이지로 이동
                  MaterialPageRoute(builder: (c) => Upload(
                      userImage: userImage,
                      setUserContent: setUserContent,
                      addMyData: addMyData))
              );
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