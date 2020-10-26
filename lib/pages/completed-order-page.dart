import 'dart:async';
import 'dart:convert';

import 'package:ZeloApp/models/Order.dart';
import 'package:ZeloApp/services/Storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ignore: must_be_immutable
class CompletedOrderPage extends StatefulWidget{
  WebSocketChannel channel;
  final Order order;

  CompletedOrderPage({Key key, this.order}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    var token = Storage.shared.getItem("token");
    channel = IOWebSocketChannel.connect('wss://zelodostavka.me/ws/?token='+token);
//    channel = IOWebSocketChannel.connect('ws://localhost:8000/ws/');
    return new CompletedOrderPageState();
  }
}

class CompletedOrderPageState extends State<CompletedOrderPage>  {

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Send a message'),
              ),
            ),
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(snapshot.hasData ? '${snapshot.data}' : 'Text'),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      var message = {
        'type': 'NEW_ORDER',
        'order': widget.order.toJson()
      };
      var json = {'message': message};

      String jsonString = jsonEncode(json);
      print(jsonString);
      widget.channel.sink.add(jsonString);
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
//  @override
//  void initState() {
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold (
//        appBar: AppBar(
//          title: Text(
//            'Статус заказа',
//            style: GoogleFonts.openSans(
//
//            ),
//          ),
//        ),
//        body: Container(
//          alignment: Alignment.center,
//          child: Text(
//            'Ваш заказ принят и уже готовиться'
//          ),
//        )
//    );
//  }

}
