
import 'dart:convert';

import 'package:ZeloApp/models/Order.dart';
import 'package:ZeloApp/models/Place.dart';
import 'package:ZeloApp/pages/profie/order-details-page.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MyOrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyOrdersPageState();
  }
}

class MyOrdersPageState extends State<MyOrdersPage> {

  List<Order> _orders = new List();

  @override
  void initState() {
    super.initState();

    _loadOrders();
  }

  void _loadOrders() async {
    String url = Network.api + '/user_orders/';
    var response = await http.get(url, headers: Network.shared.headers());

    var ordersJson = json.decode(response.body).cast<Map<String, dynamic>>();

    var ordersList = new List<Order>();

    ordersJson.forEach((element) {
      var order = Order.fromJson(element);
      ordersList.add(order);
    });

    setState(() {
      _orders = ordersList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('Мои заказы'),
      ),
      body: ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, i) {
            if (i == 0) {
              return _buildHeader();
            } else {
              return _buildOrderCell(_orders[i]);
            }
          }
      ),
      backgroundColor: Colors.grey[50],
    );
  }

  Widget _buildHeader() {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding (
          padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
          child: Text(
            'Ваши заказы',
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildOrderCell(Order order) {
    return InkWell (
      onTap: () {
        Navigator.push(context,CupertinoPageRoute(builder: (context) =>
            OrderDetailsPage(
                order: order
            )
        ));
      },
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border:  Border (
              bottom: BorderSide (
                  color: Colors.grey[200],
                  width: 1
              ),
            )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    order.place.name,
                    style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7)
                    ),
                  ),

                  Text(
                    order.formatedDate(),
                    style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.grey
                    ),
                  )
                ],
              ),
            ),

            Padding (
              padding: EdgeInsets.only(right: 10),
              child: Text(
                order.total().toString(),
                style: GoogleFonts.openSans(
                    fontSize: 18,
                    color: Colors.black.withOpacity(0.7)
                ),
              ),
            ),

            Container(
              height: 15,
              width: 15,
              child: Image(
                image: AssetImage("assets/images/right-arrow.png"),
              ),
            )

          ],
        ),
      ),
    );
  }

}