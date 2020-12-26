import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OrderCommentPage extends StatelessWidget {
  final _myController = TextEditingController();
  String comment = '';

  OrderCommentPage(comment) {
    this.comment = comment;
    _myController.text = comment;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() {
        Navigator.pop(context, _myController.text);
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.0,
            iconTheme: IconThemeData(
                color: Colors.black
            ),
          ),
          body: Container(
              color: Colors.white,
              height: double.infinity,
              padding: EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                controller: _myController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 100,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Комментарий к заказу',
                ),
              )
          )
      ),
    );
  }

}