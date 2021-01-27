import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner; //qrscan 패키지를 scanner 별칭으로 사용.
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:websocket_manager/websocket_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = 'Empty Scan Code';
  WebsocketManager socket;

  @override
  initState() {
    super.initState();
    socket = WebsocketManager('http://59.17.26.162:8080/echo/alarm');
    if (socket != null) {
      socket.connect();

      print('socket = $socket');
      print('socket.url = ${socket.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              //정 가운데에 QR 스켄값 표시
              child: Text(_output, style: TextStyle(color: Colors.black)),
            );
          },
        ),
        //플로팅 액션 버튼으로 qr 스캔 함수 실행
        floatingActionButton: FloatingActionButton(
          onPressed: () => _scan(),
          tooltip: 'scan',
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  //비동기 함수
  Future _scan() async {
    //스캔 시작 - 이때 스캔 될때까지 blocking
    print('await.....');
    String barcode = await scanner.scan();
    //스캔 완료하면 _output 에 문자열 저장하면서 상태 변경 요청.
    var response = await http.get(barcode);
    String responseBody = utf8.decode(response.bodyBytes);
    print('responseBody = $responseBody await finish');
    setState(() => {
          _output = barcode,
          print('output = $_output'),
        });

    String message = '''
    {
    "type":"2",
    "user":"manki",
    "cafe":"Q01B" 
    }
    ''';
    if (socket != null) {
      print('sendMessage = $message');
      socket.send(message);
    }
  }
}
