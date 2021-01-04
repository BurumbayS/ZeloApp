
import 'package:ZeloApp/pages/order-page/order-page.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SectionType {
  delivery,
  status,
  total,
  itemsHeader,
  detailedTotal
}

class OrderDetailsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new OrderDetailsPageState();
  }
}

class OrderDetailsPageState extends State<OrderDetailsPage> {

  var sections = [SectionType.delivery, SectionType.status, SectionType.total, SectionType.itemsHeader, SectionType.detailedTotal];
  var items = ["","",""];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: "Lanzhou",
              style: TextStyle(fontSize: 20),
              children: <TextSpan>[
                TextSpan(
                  text: '\n20.12.2020',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300]
                  ),
                ),
              ]
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: sections.length + items.length,
        itemBuilder: (context, i) {

          if (i < sections.length - 1) {
            switch (sections[i]) {
              case SectionType.delivery:
                return _deliverySection();
              case SectionType.status:
                return _statusSection();
              case SectionType.total:
                return _totalSection();
              case SectionType.itemsHeader:
                return _itemsHeader();
            }
          }

          if (i == items.length + sections.length - 1) {
            return _detailedTotal();
          }

          return _orderItem();
        }
      )
    );
  }

  Widget _deliverySection() {
    return Padding (
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Доставка',
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.place,
                  color: Colors.blue,
                ),

                Padding (
                  padding: EdgeInsets.only(left: 10),
                  child: Text (
                    'Жансугурова 88/86',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            )
          ),

          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.attach_money,
                    color: Colors.blue,
                  ),

                  Padding (
                    padding: EdgeInsets.only(left: 10),
                    child: Text (
                      '400 KZT',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  )
                ],
              )
          ),

        ],
      ),
    );
  }

  Widget _statusSection() {
    return Padding (
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              'Статус заказа',
              style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),

          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.room_service,
                    color: Colors.blue,
                  ),

                  Padding (
                    padding: EdgeInsets.only(left: 10),
                    child: Text (
                      'Заказ доставлен',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              )
          ),

        ],
      ),
    );
  }

  Widget _totalSection() {
    return Padding (
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              'Итого',
              style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),

          Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.local_grocery_store,
                    color: Colors.blue,
                  ),

                  Padding (
                    padding: EdgeInsets.only(left: 10),
                    child: Text (
                      '7820 KZT',
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              )
          ),

        ],
      ),
    );

  }

  Widget _itemsHeader() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Padding(
        padding: EdgeInsets.only(top: 30),
        child: Text(
          'Детали заказа',
          style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _orderItem() {
    return Container(
      padding: EdgeInsets.only(top: 10, right: 15, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Burger классический asdasdas ad asd asd asd asd ',
                  maxLines: 3,
                  style: GoogleFonts.openSans(
                      fontSize: 14
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '1 x',
                  style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              Padding (
                padding: EdgeInsets.only(left: 5),
                child: Text (
                    '2015 = 3201'
                ),
              )
            ],
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: DottedLine(
              dashColor: Colors.grey,
            ),
          )
        ],
      )
    );
  }

  Widget _detailedTotal() {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              children: <Widget>[
                Text(
                  'ЗАКАЗ',
                ),

                Expanded(
                  child: DottedLine(
                    dashColor: Colors.grey,
                  ),
                ),

                Text(
                  '2015 KZT',
                  style: TextStyle(
                      fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              children: <Widget>[
                Text(
                  'ДОСТАВКА',
                ),

                Expanded(
                  child: DottedLine(
                    dashColor: Colors.grey,
                  ),
                ),

                Text(
                  '2015 KZT',
                  style: TextStyle(
                      fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              children: <Widget>[
                Text(
                  'ИТОГО',
                  style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold
                  ),
                ),

                Expanded(
                  child: DottedLine(
                    dashColor: Colors.grey,
                  ),
                ),

                Text(
                  '2015 KZT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}