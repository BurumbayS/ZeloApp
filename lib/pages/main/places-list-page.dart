import 'dart:convert';

import 'package:ZeloApp/models/Place.dart';
import 'package:ZeloApp/models/User.dart';
import 'package:ZeloApp/pages/place/place-profile.dart';
import 'package:ZeloApp/pages/profie/profile-page.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/services/Storage.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../auth/auth-page.dart';

class PlacesListState extends State<PlacesList> {

  City _selectedCity;
  bool _citySelecting = false;

  List<Place> _places = new List();
  bool _placesLoaded = false;

  var _loading = false;

  @override
  void initState() {
    super.initState();

    _identifyCity();
  }

  void _identifyCity() async {
      String city = await Storage.itemBy("city");

      if (city == null) {
        setState(() {
          _citySelecting = true;
        });
        return;
      }

      if (city == City.Semey.toString()) {
        Network.shared.setCity(City.Semey);
        setState(() {
          _selectedCity = City.Semey;
        });
      }
      if (city == City.Taldykorgan.toString()) {
        Network.shared.setCity(City.Taldykorgan);
        setState(() {
          _selectedCity = City.Taldykorgan;
        });
      }
      if (city == City.Taraz.toString()) {
        Network.shared.setCity(City.Taraz);
        setState(() {
          _selectedCity = City.Taraz;
        });
      }

      _loadPlaces();
  }

  void _selectCity(City city) {
    setState(() {
      _citySelecting = false;
      _selectedCity = city;
    });

    Network.shared.setCity(city);
    Storage.setItem('city', city.toString());

    _loadPlaces();
  }

  String _selectedCityTitle() {
    switch (_selectedCity) {
      case City.Taldykorgan:
        return "Талдыкорган";
      case City.Semey:
        return "Семей";
      case City.Taraz:
        return "Тараз";
    }

    return "";
  }

  void _loadPlaces() async {
    setState(() {
      _loading = true;
      _places = [];
      _placesLoaded = false;
    });

    String url = Network.shared.api + '/places/';
    var response = await http.get(url);

    var placesJson = json.decode(response.body).cast<Map<String, dynamic>>();

    var placesList = new List<Place>();

    placesJson.forEach((element) {
      var place = Place.fromJson(element);
      placesList.add(place);
    });

    setState(() {
      _places = placesList;
      _placesLoaded = true;
      _loading = false;
    });
  }

  void _goToProfile() async {
    var _isAuthenticated = await User.isAuthenticated();

    if (_isAuthenticated) {
      Navigator.push(context,CupertinoPageRoute(builder: (context) => ProfilePage()));
    } else {
      showDialog(context: context, builder: (_) => CustomAlertDialog.shared.dialog("Хотите зарегистрироваться?\n", "Для заказа блюда вам необходимо зарегистрироваться", false, context, () {
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
            if (!_loading) {
              setState(() {
                _citySelecting = !_citySelecting;
              });
            }
          },
          child: Text(
            _selectedCityTitle(),
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

          (_placesLoaded && _places.length == 0) ? Center(
            child: Padding(
              padding: EdgeInsets.only(left: 50, right: 50, bottom: 100),
              child:  Text(
                'Скоро здесь будут ваши любимые заведения',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  color: Colors.grey
                ),
              ),
            )
          ) : Container(),

          Positioned(
            width: (_citySelecting) ? MediaQuery.of(context).size.width : 0,
            height: (_citySelecting) ? MediaQuery.of(context).size.height : 0,
            top: 0,
            left: 0,
            child: Container(
                color: Colors.black.withOpacity(0.3),
                alignment: Alignment.center,
                child: Center (
                  child: _citySelectionModalView(),
                )
            ),
          ),

          (_loading) ? Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(bottom: 150),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),]
                    ),
                    child: SpinKitFadingCircle(
                        color: Colors.grey
                    ),
                  ),
                )
            ),
          ) : Container()
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

        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: <Widget>[

                ClipRRect (
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),

                  child: SizedBox (
                    height: 130,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: (place.wallpaper != null) ? Network.shared.host() + place.wallpaper : "",
                      placeholder: (context, url) => Image.asset('assets/images/place_placeholder.png', fit: BoxFit.cover,),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
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
                                maxLines: 1,
                                style: GoogleFonts.openSans(
                                    fontSize: 18,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w700
                                ),
                                overflow: TextOverflow.ellipsis,
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
                          margin: EdgeInsets.only(right: 10, top: 7, left: 10),
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
        margin: EdgeInsets.only(bottom: 200, left: 30, right: 30),
        height: 200,
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Выберите ваш город',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _selectCity(City.Taldykorgan);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: (_selectedCity == City.Taldykorgan) ? Colors.blue : Colors.white,
                ),
                child: Text(
                  'Талдыкорган',
                  style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: (_selectedCity == City.Taldykorgan) ? Colors.white : Colors.blue
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _selectCity(City.Semey);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: (_selectedCity == City.Semey) ? Colors.blue : Colors.white,
                ),
                child: Text(
                  'Семей',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    color: (_selectedCity == City.Semey) ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            ),
//            InkWell(
//              onTap: () {
//                _selectCity(City.Taraz);
//              },
//              child: Container(
//                height: 50,
//                width: double.infinity,
//                margin: EdgeInsets.only(bottom: 10),
//                alignment: Alignment.center,
//                decoration: BoxDecoration(
//                  borderRadius: BorderRadius.all(Radius.circular(5)),
//                  color: (_selectedCity == City.Taraz) ? Colors.blue : Colors.white,
//                ),
//                child: Text(
//                  'Тараз',
//                  style: GoogleFonts.openSans(
//                      fontSize: 18,
//                      color: (_selectedCity == City.Taraz) ? Colors.white : Colors.blue
//                  ),
//                ),
//              ),
//            ),
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