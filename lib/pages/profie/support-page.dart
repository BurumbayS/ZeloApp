
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SupportPageState();
  }
}

class SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Служба поддержки'
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Semey
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Талдыкорган",
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  color: Colors.grey
                ),
              ),
            ),

            Row(
              children: <Widget>[
                Text(
                  'Email: ',
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 20
                  ),
                ),
                Text(
                  'zelo.dostavka@mail.ru',
                  style: GoogleFonts.openSans(
                      color: Colors.blue,
                      fontSize: 20
                  ),
                )
              ],
            ),

            Divider(
              color: Colors.grey,
            ),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  launch('https://www.instagram.com/zelo_dostavka/');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Instagram: ',
                      style: GoogleFonts.openSans(
                          color: Colors.black,
                          fontSize: 20
                      ),
                    ),
                    Text(
                      '@zelo_dostavka',
                      style: GoogleFonts.openSans(
                          color: Colors.blue,
                          fontSize: 20
                      ),
                    )
                  ],
                ),
              ),
            ),

            Divider(
              color: Colors.grey,
            ),

            InkWell (
              onTap: () {
                launch("tel://+77773789193");
              },
              child: Row(
                children: <Widget>[
                  Text(
                    'Тел.: ',
                    style: GoogleFonts.openSans(
                        color: Colors.black,
                        fontSize: 20
                    ),
                  ),
                  Text(
                    '+7 (777) 378-91-93',
                    style: GoogleFonts.openSans(
                        color: Colors.blue,
                        fontSize: 20
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 20),
              child: DottedLine(),
            ),

            //Semey
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                "Семей",
                style: GoogleFonts.openSans(
                    fontSize: 18,
                    color: Colors.grey
                ),
              ),
            ),

            Row(
              children: <Widget>[
                Text(
                  'Email: ',
                  style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: 20
                  ),
                ),
                Text(
                  'zelo.dostavka@mail.ru',
                  style: GoogleFonts.openSans(
                      color: Colors.blue,
                      fontSize: 20
                  ),
                )
              ],
            ),

            Divider(
              color: Colors.grey,
            ),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: InkWell(
                onTap: () {
                  launch('https://www.instagram.com/zelo_dostavka_semey/');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Instagram: ',
                      style: GoogleFonts.openSans(
                          color: Colors.black,
                          fontSize: 20
                      ),
                    ),
                    Text(
                      '@zelo_dostavka_semey',
                      style: GoogleFonts.openSans(
                          color: Colors.blue,
                          fontSize: 20
                      ),
                    )
                  ],
                ),
              ),
            ),

            Divider(
              color: Colors.grey,
            ),

            InkWell (
              onTap: () {
                launch("tel://+77072980444");
              },
              child: Row(
                children: <Widget>[
                  Text(
                    'Тел.: ',
                    style: GoogleFonts.openSans(
                        color: Colors.black,
                        fontSize: 20
                    ),
                  ),
                  Text(
                    '+7 (707) 298-04-44',
                    style: GoogleFonts.openSans(
                        color: Colors.blue,
                        fontSize: 20
                    ),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

}