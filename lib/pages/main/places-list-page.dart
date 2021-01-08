import 'dart:convert';

import 'package:ZeloApp/models/Place.dart';
import 'package:ZeloApp/models/User.dart';
import 'package:ZeloApp/pages/place/place-profile.dart';
import 'package:ZeloApp/pages/profie/profile-page.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../auth/auth-page.dart';

class PlacesListState extends State<PlacesList> {

  String _selectedCity = "Талдыкорган";
  bool _citySelecting = false;
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
        title: InkWell(
          onTap: () {
            setState(() {
              _citySelecting = !_citySelecting;
            });
          },
          child: Text(
            _selectedCity,
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
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
      body: Stack(
        children: <Widget>[
          _buildList(),

          Positioned(
            width: (_citySelecting) ? MediaQuery.of(context).size.width : 0,
            height: (_citySelecting) ? MediaQuery.of(context).size.height : 0,
            top: 0,
            left: 0,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _citySelectionModalView(),
                ],
              )
            ),
          ),
        ],
      ),
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
                              'от ' + place.deliveryMinPrice.toString() + ' KZT',
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
        height: 195,
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

  Widget _citySelectionModalView() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: (_citySelecting) ? 1.0 : 0,
      child: Container(
//        margin: EdgeInsets.only(top: 250),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  _selectedCity = "Талдыкорган";
                  _citySelecting = false;
                });
              },
              child: Container(
                height: 50,
                width: 200,
                margin: EdgeInsets.only(bottom: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: (_selectedCity == "Талдыкорган") ? Colors.blue : Colors.white,
                ),
                child: Text(
                  'Талдыкорган',
                  style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: (_selectedCity == "Талдыкорган") ? Colors.white : Colors.blue
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedCity = "Семей";
                  _citySelecting = false;
                });
              },
              child: Container(
                height: 50,
                width: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: (_selectedCity == "Семей") ? Colors.blue : Colors.white,
                ),
                child: Text(
                  'Семей',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    color: (_selectedCity == "Семей") ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            )
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