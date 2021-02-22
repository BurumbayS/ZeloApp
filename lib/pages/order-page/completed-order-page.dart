import 'dart:async';
import 'dart:convert';

import 'package:ZeloApp/models/Order.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class CompletedOrderPage extends StatefulWidget{
  final Order order;

  CompletedOrderPage({Key key, this.order}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new CompletedOrderPageState();
  }
}

class CompletedOrderPageState extends State<CompletedOrderPage>  {

  @override
  void initState() {
    super.initState();
  }

  void _cancelOrder() {
    showDialog(context: context, builder: (_) =>
        CustomAlertDialog.shared.dialog("Постойте", "Вы уверены, что хотите отменить заказ?", false, context, () async {
          var id = widget.order.id;
          var response = await http.get(Network.shared.api + "/cancel_order/$id/");

          var json = jsonDecode(response.body);

          if (json['code'] == 0) {
            showDialog(context: context, builder: (_) =>
                CustomAlertDialog.shared.dialog("Успешно", "Ваш заказ отменен", true, context, () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                })
            );
          }
        })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar(
          title: Text(
            'Статус заказа',
            style: GoogleFonts.openSans(

            ),
          ),
          leading: new Container(),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Column (
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  child: Image(
                    image: AssetImage('assets/images/courier.png'),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Поздравляем!',
                  style: GoogleFonts.openSans(
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue
                  ),
                ),
              ),
              Text(
                  'Ваш заказ принят и уже готовиться',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 18
                ),
              ),

              RichText (
                textAlign: TextAlign.center,
                text: TextSpan(
                    children: <TextSpan> [
                      TextSpan(
                          text: 'Приблизительное время доставки ',
                          style: GoogleFonts.openSans(
                              fontSize: 18,
                            color: Colors.black
                          )
                      ),
                      TextSpan (
                          text: '30-40 мин',
                          style: GoogleFonts.openSans(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.w600
                          ),
                      )
                    ]
                ),
              ),

              Container(
                height: 50,
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    boxShadow: [BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),]
                ),

                child: FlatButton(
                  color: Colors.blue[400],
                  textColor: Colors.white,
                  splashColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)
                  ),

                  child: Text(
                      'Готово',
                      style: GoogleFonts.openSans(
                          color: Colors.white ,
                          fontSize: 22,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  onPressed: (){
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),

              Container(
                height: 50,
                margin: EdgeInsets.only(top: 20, bottom: 50),
                width: MediaQuery.of(context).size.width * 0.8,

                child: FlatButton(
                  color: Colors.white.withOpacity(0.01),
                  textColor: Colors.redAccent,
                  splashColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.redAccent,
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                  ),

                  child: Text(
                      'Отменить заказ',
                      style: GoogleFonts.openSans(
                          color: Colors.redAccent,
                          fontSize: 22,
                          decoration: TextDecoration.none,
//                          fontWeight: FontWeight.bold
                      )
                  ),
                  onPressed: (){
                    _cancelOrder();
                  },
                ),
              ),
            ],
          )
        )
    );
  }

}
