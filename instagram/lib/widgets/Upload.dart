import 'package:flutter/material.dart';

class Upload extends StatelessWidget {
  Upload({super.key, this.userImage, this.setUserContent, this.addMyData});

  final userImage;
  final setUserContent;
  final addMyData;
  var inputData = TextEditingController();      // 입력한 텍스트를 저장하기 위함

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("새 게시물", style: TextStyle(fontSize: 20),),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){ Navigator.pop(context); },
          icon: Icon(Icons.close),
          color: Colors.black,
        ),
        actions: [
          TextButton(                         // 최종 게시물 업로드 버튼
              onPressed: (){
                if (inputData != null){
                  setUserContent(inputData.text);}
                addMyData();                    // 게시물을 data에 추가
                Navigator.pop(context);
              },
              child: Text("공유", style: TextStyle(fontSize: 15),)
          )
        ],
      ),
      body: Column(
        children: [
          Image(image: ResizeImage(FileImage(userImage), width: 500, height: 500)),
          TextField(
            controller: inputData,
            decoration: InputDecoration(
              hintText: "  문구를 입력해주세요",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}