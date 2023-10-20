import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import './Profile.dart';

///////////////////////////////////////
//   글 위젯 (사진, 좋아요, 글쓴이, 내용)   //
///////////////////////////////////////
class Home extends StatefulWidget {
  Home({super.key, this.data, this.isVisible, this.isVisibleCallback});

  final data;
  var isVisible;
  final isVisibleCallback;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var scroll = ScrollController(); // 스크롤 상태를 저장

  // 서버에서 데이터를 더 받아오는 함수
  getMore() async {
    var result = await http.get(
        Uri.parse("https://codingapple1.github.io/app/more1.json"));
    var result2 = json.decode(result.body);
    setState(() {
      widget.data.add(result2); // 받아온 data를 기존 부모 위젯의 data에 추가
    });
  }

  @override
  // Home 위젯이 로드될 때 실행됨
  void initState() {
    super.initState();
    scroll.addListener(() { // 스크롤 상태가 변경될 때마다 실행됨
      if (scroll.position.pixels ==
          scroll.position.maxScrollExtent) { // 스크롤 위치가 끝일 때
        getMore(); // 처음 실행될 때 데이터를 추가로 받아옴
      }
      if (scroll.position.userScrollDirection.toString() ==
          "ScrollDirection.reverse") { // 스크롤 내릴 때 하단바가 보이지 않도록 함
        widget.isVisibleCallback(
            false); // 스크롤을 내릴 때 isVisibleCallback을 호출하여 하단바 숨김
      }
      else if (scroll.position.userScrollDirection.toString() ==
          "ScrollDirection.forward") {
        widget.isVisibleCallback(
            true); // 스크롤 방향이 다른 경우 isVisibleCallback을 호출하여 하단바 표시
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(itemCount: widget.data.length,
          controller: scroll,
          itemBuilder: (c, i) {
            return Column(
              children: [
                widget.data[i]["image"].runtimeType ==
                    String // 저장된 이미지가 주소 형태라면
                    ? Image.network(
                    widget.data[i]["image"]) // image network 형태로 보여줌
                    : Image.file(widget.data[i]["image"]), // image file 형태로 보여줌
                Container(
                  margin: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("좋아요 ${widget.data[i]["likes"].toString()}",
                        style: TextStyle(fontWeight: FontWeight.bold),),

                      GestureDetector(
                        child: Text(widget.data[i]["user"],), // 글쓴이
                        onTap: () {
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (c) => Profile())
                          );
                        },
                      ),

                      Text(widget.data[i]["content"]), // 글내용
                    ],
                  ),
                ),
              ],
            );
          });
    } else { // data가 아직 안 들어왔을 때(도착하지 않았을 때)
      return Center(
          child: CircularProgressIndicator()
      );
    }
  }
}
