
import 'dart:convert';

import 'package:ZeloApp/models/Address.dart';
import 'package:ZeloApp/services/MapApi.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'map-page.dart';

class BBox {
  Point leftBottom;
  Point rightTop;

  BBox(Point leftBottom, Point rightTop) {
    this.leftBottom = leftBottom;
    this.rightTop = rightTop;
  }
}

class AddressSearchPage extends StatefulWidget {

  Address address;
  Coordinates placeCoordinates;

  AddressSearchPage({Key key, this.address, this.placeCoordinates}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AddressSearchPageState();
  }
}

class AddressSearchPageState extends State<AddressSearchPage> {

  final TaldykkBox = BBox(Point(latitude: 44.975728, longitude: 78.300946), Point(latitude: 45.060002, longitude: 78.448917));
  final TarazBox = BBox(Point(latitude: 42.837710, longitude: 71.242950), Point(latitude: 43.042798, longitude: 71.563141));
  final SemeyBox = BBox(Point(latitude: 50.333628, longitude: 80.097300), Point(latitude: 50.489405, longitude: 80.356962));

  var _searchText = "";
  List<Address> _searchResults = [];

  var _addressTextController = new TextEditingController();

  var _focusOnAddress = FocusNode();
  var _focusOnSubAddress = FocusNode();

  double _completeBtnBottomMargin = -50;

  var _loading = false;
  var _distanceCalculating = false;

  void _searchAddress(String address) async {
    _searchText = address;

    await Future.delayed(Duration(milliseconds: 500));

    if (_searchText != address) { return; }

    //3e4e92eb-53cc-44a8-81ac-7788a8144e4b
    //b5e16ac6-6e22-4a90-8940-25d258b393e6
    var baseURL = "https://search-maps.yandex.ru/v1/?type=geo&lang=ru_RU&apikey=3e4e92eb-53cc-44a8-81ac-7788a8144e4b";

    var bbox = "${TaldykkBox.leftBottom.longitude},${TaldykkBox.leftBottom.latitude}~${TaldykkBox.rightTop.longitude},${TaldykkBox.rightTop.latitude}";
    var requestURL = "$baseURL&text=$address&bbox=$bbox";

    var response = await http.get(requestURL);
    var responseJson = jsonDecode(response.body);

    _searchResults = [];

    for (Map<String, dynamic> item in responseJson["features"]) {
      var place = Address();
      place.firstAddress = item["properties"]["name"];
      place.description = item["properties"]["description"];
      place.latitude = item["geometry"]["coordinates"][1];
      place.longitude = item["geometry"]["coordinates"][0];

      setState(() {
        _searchResults.add(place);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadMapApiKey();

    _addressTextController.text = widget.address.firstAddress;
    _controlCompleteButton();

    _focusOnAddress.addListener(() {
      _controlCompleteButton();
    });

    _focusOnSubAddress.addListener(() {
      _controlCompleteButton();
    });
  }

  void _loadMapApiKey() async {
    if (MapApi.shared.searchKey != null) {
      return;
    }

    setState(() {
      _loading = true;
    });

    Response response = await Dio().get(Network.shared.api + "/addressSearchApiKey/");

    if (response.data['code'] == 0) {
      MapApi.shared.searchKey = response.data['key'];
    }

    setState(() {
      _loading = false;
    });
  }

  void _controlCompleteButton() async {
    if (!_focusOnAddress.hasFocus && !_focusOnSubAddress.hasFocus && widget.address.longitude != null) {
      await Future.delayed(Duration(milliseconds: 100));

      setState(() {
        _completeBtnBottomMargin = 50;
      });
    } else {
      setState(() {
        _completeBtnBottomMargin = -50;
      });
    }
  }

  void _calculateDistance() async {
    setState(() {
      _distanceCalculating = true;
    });

    Response distanceResponse = await Dio().get("https://maps.googleapis.com/maps/api/distancematrix/json?language=ru_RU&units=metric&origins=${widget.placeCoordinates.latitude},${widget.placeCoordinates.longitude}&destinations=${widget.address.latitude},${widget.address.longitude}&key=AIzaSyDxgI8Z7Tw33nw46fsN98hEEwTdqgZoCBY");

    int distanceInMeters = distanceResponse.data['rows'][0]['elements'][0]['distance']['value'];
    widget.address.distance = distanceInMeters;

    setState(() {
      _distanceCalculating = false;
    });
  }

  void _setAddress(Address address) {
    widget.address = address;
    _addressTextController.text = widget.address.firstAddress;

    _searchResults = [];

    _controlCompleteButton();
    _calculateDistance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Адрес",
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0, top: 18),
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapSearchPage(widget.address, widget.placeCoordinates)
                      )
                  );

                  if (result != null) {
                    setState(() {
                      _setAddress(result);
                    });
                  }
                },
                child: Text (
                  "Карта",
                  style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 18
                  ),
                ),
              )
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
                  child: Text(
                    "Укажите свой адрес или найдите на карте",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.blue
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: TextFormField(
                  controller: _addressTextController,
                  focusNode: _focusOnAddress,
                  keyboardType: TextInputType.text,
                  onChanged: (address) {
                    setState(() {
                      widget.address = Address();
                    });

                    _searchAddress(address);
                  },
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                      hintText: 'Укажите свой адрес',
                      hintStyle: GoogleFonts.openSans(
                          color: Colors.grey[500]
                      )
                  ),
                  style: GoogleFonts.openSans(
                      fontSize: 18
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: TextFormField(
                  focusNode: _focusOnSubAddress,
                  initialValue: widget.address.secondAddress,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    setState(() {
                      widget.address.secondAddress = text;
                    });
                  },
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                      hintText: 'Подъезд, квартира и т.д',
                      hintStyle: GoogleFonts.openSans(
                          color: Colors.grey[500]
                      )
                  ),
                  style: GoogleFonts.openSans(
                      fontSize: 18
                  ),
                ),
              ),

              Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return _suggestedAddress(_searchResults[index]);
                      },
                    ),
                  )
              )
            ],
          ),

          Positioned (
            bottom: _completeBtnBottomMargin,
            left: MediaQuery.of(context).size.width * 0.1,

            child: Container(
              height: 50,
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

                child: (!_distanceCalculating) ? Text(
                    'Подтвердить адрес',
                    style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 22,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold
                    )
                ) : Padding(
                  padding: EdgeInsets.all(5),
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),

                onPressed: (){
                  if (!_distanceCalculating) {
                    Navigator.pop(context, widget.address);
                  }
                },
              ),
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
      )
    );
  }

  Widget _suggestedAddress(Address address) {
    return InkWell(
      onTap: () {
        setState(() {
          _setAddress(address);
        });

        FocusScope.of(context).unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10 ,right: 20),
            child: Text(
              address.firstAddress,
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 20, top: 5, right: 20),
            child: Text(
              address.description,
              style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey
              ),
            ),
          ),

          Divider()
        ],
      ),
    );
  }
}