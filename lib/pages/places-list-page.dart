import 'dart:convert';

import 'package:ZeloApp/models/Place.dart';
import 'package:ZeloApp/models/User.dart';
import 'package:ZeloApp/pages/place-profile.dart';
import 'package:ZeloApp/pages/profie/profile-page.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'auth/auth-page.dart';

class PlacesListState extends State<PlacesList> {

  int _price = 400;
  List<Place> _places = new List();

  @override
  void initState() {
    super.initState();

    loadPlaces();
  }

  void loadPlaces() async {
    String url = Network.api + '/places/';
    var response = await http.get(url);

    var placesJson = json.decode(response.body).cast<Map<String, dynamic>>();

    var placesList = new List<Place>();

    placesJson.forEach((element) {
      var place = Place.fromJson(element);
      placesList.add(place);
    });

    setState(() {
      _places = placesList;
    });
  }

  void _goToProfile() async {
    var _isAuthenticated = await User.isAuthenticated();

    if (_isAuthenticated) {
      Navigator.push(context,CupertinoPageRoute(builder: (context) => ProfilePage()));
    } else {
      showDialog(context: context, builder: (_) => CustomAlertDialog.shared.dialog("Хотите зарегестрироваться?\n", "Для заказа блюда вам необходимо зарегестрироваться", false, context, () {
        Navigator.pop(context);
        Navigator.of(context).push(
            MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => AuthPage()
            )
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Zelo',
            style: GoogleFonts.yellowtail(
              fontSize: 40,
              color: Colors.white,
            )
        ),
        actions: <Widget>[
          Container(
              child: IconButton(
                onPressed: () {
                  _goToProfile();
                },
                icon: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              )
          ),
        ],
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
        itemCount: _places.length,
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, i) {
          return _buildRow(_places[i]);
        }
    );
  }

  Widget _buildRow(Place place) {
    return InkWell(
      onTap: (){
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => PlaceProfile(place)));
      },

      child: Container(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: <Widget>[

            ClipRRect (
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),

              child: SizedBox (
                height: 130,
                width: double.infinity,
                child: Image.network(
                  Network.host + place.wallpaper,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            Container(
              width: double.infinity,

              child: Row(

                children: <Widget>[

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container (
                          margin: EdgeInsets.only(left: 10, top: 10),
                          child: Text(
                              place.name,
                              style: GoogleFonts.capriola(
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500
                              )
                          ),
                        ),

                        Container (
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                              place.description,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.capriola(
                                fontSize: 14,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w100,
                              )
                          ),
                        )
                      ],
                    ),
                  ),

                  Container(
                      margin: EdgeInsets.only(right: 10, top: 7),
//                  height: 40,
                      padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),

                      child: Column(
                        children: <Widget>[

                          Text(
                              'Доставка',
                              style: GoogleFonts.montserratAlternates(
                                fontSize: 16,
                                color: Colors.blue,
                              )
                          ),

                          Text(
                              place.deliveryMinPrice.toString() + ' ₸',
                              style: GoogleFonts.montserratAlternates(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              )
                          ),
                        ],
                      )

                  ),

                ],
              ),

            )

          ],
        ),

        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
      ),
    );
  }

}

class PlacesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PlacesListState();
  }
}