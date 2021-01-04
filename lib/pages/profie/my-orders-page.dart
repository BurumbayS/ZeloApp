
import 'package:ZeloApp/pages/profie/order-details-page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyOrdersPageState();
  }
}

class MyOrdersPageState extends State<MyOrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text('Мои заказы'),
      ),
      body: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, i) {
            if (i == 0) {
              return _buildHeader();
            } else {
              return _buildOrderCell();
            }
          }
      ),
      backgroundColor: Colors.grey[100],
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

  Widget _buildOrderCell() {
    return InkWell (
      onTap: () {
        Navigator.push(context,CupertinoPageRoute(builder: (context) => OrderDetailsPage()));
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
                    'Lanzhou',
                    style: GoogleFonts.openSans(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7)
                    ),
                  ),

                  Text(
                    '20.12.2020',
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
                '1204',
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