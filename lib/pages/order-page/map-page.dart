import 'dart:async';
import 'dart:io';

import 'package:ZeloApp/models/Address.dart';
import 'package:ZeloApp/services/MapApi.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/services/Storage.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:flutter/cupertino.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as geolocator;

import 'delivery-address-details.dart';

// ignore: must_be_immutable
class MapSearchPage extends StatefulWidget{

  Address myAddress;
  Address newAddress;
  Coordinates placeCoordinates;

  MapSearchPage(Address address, Coordinates placeCoordinates) {
    this.myAddress = address;
    this.placeCoordinates = placeCoordinates;
  }

  @override
  State<StatefulWidget> createState() {
    return new MapSearchPageState(this.myAddress);
  }
}

class MapSearchPageState extends State<MapSearchPage>  {

  static const PLACE_API_KEY = "AIzaSyC4ATGNItCqpljzi47MRKMFGRT-ZNZvtJg";
  static const _allowedTaldykorganRegions = ["Талдыкорган", "село Еркин", "село Отенай"];

  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  bool _loading = false;

  int _requestCount = 0;
  Address address = new Address();
  City currentCity;

  YandexMapController controller;

  var _showingAlert = false;

  @override
  void initState() {
    super.initState();

    _loadMapApiKey();
    _requestPermission();
  }

  void _loadMapApiKey() async {
    if (MapApi.shared.mapKey != null) {
      return;
    }

    Response response = await Dio().get(Network.shared.api + "/mapApiKey/");

    if (response.data['code'] == 0) {
      MapApi.shared.mapKey = response.data['key'];
    }
  }

  Future<void> _requestPermission() async {
    final List<PermissionGroup> permissions = <PermissionGroup>[PermissionGroup.location];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
    await PermissionHandler().requestPermissions(permissions);
    setState(() {
      _permissionStatus = permissionRequestResult[PermissionGroup.location];
    });
  }

  MapSearchPageState(Address address) {
    this.address = address;
  }

  Future<void> cameraPositionChanged(dynamic arguments) async {
    _requestCount++;
    int currentRequestCount = _requestCount;

    await Future.delayed(Duration(milliseconds: 100));

    if (_requestCount == currentRequestCount) {
      setState(() {
        _loading = true;
      });

      double lat = arguments['latitude'];
      double long = arguments['longitude'];

      double placeLat = widget.placeCoordinates.latitude;
      double placeLong = widget.placeCoordinates.longitude;

      address.latitude = lat;
      address.longitude = long;

      String baseURL = "https://geocode-maps.yandex.ru/1.x/";
      String request = '$baseURL?format=json&apikey=${MapApi.shared.mapKey}&geocode=$long,$lat';
      Response addressResponse = await Dio().get(request);

      Response distanceResponse = await Dio().get("https://maps.googleapis.com/maps/api/distancematrix/json?language=ru_RU&units=metric&origins=$placeLat,$placeLong&destinations=$lat,$long&key=AIzaSyDxgI8Z7Tw33nw46fsN98hEEwTdqgZoCBY");

      _setAddress(addressResponse);

      int distanceInMeters = distanceResponse.data['rows'][0]['elements'][0]['distance']['value'];
      address.distance = distanceInMeters;

      setState(() {
        _loading = false;
      });
    }

  }

  void _setAddress(Response addressResponse) {
    var components = addressResponse.data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']["metaDataProperty"]["GeocoderMetaData"]["Address"]["Components"];

    if (currentCity == City.Taldykorgan) {
      var allowed = false;

      for (Map component in components) {
        if (component["kind"] == "locality") {
          var region = component["name"];
          if (_allowedTaldykorganRegions.contains(region)) {
            allowed = true;
          } else {
            allowed = false;
          }
        }
      }

      if (allowed) {
        setState(() {
          String addressString = addressResponse.data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['name'];
          address.firstAddress = addressString;
        });
      } else {

        if (!_showingAlert) {
          _showingAlert = true;
          showDialog(context: context, builder: (_) =>  CustomAlertDialog.shared.dialog("Простите", "Это заведение не доставляет в данный регион", true, context, (){
            _showingAlert = false;
          } ));
        }

        setState(() {
          address.firstAddress = "";
        });
      }
    } else {
      setState(() {
        String addressString = addressResponse.data['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['name'];
        address.firstAddress = addressString;
      });
    }
  }
  
  Point _mapCenter() {
    if (address.latitude != null && address.longitude != null) {
      return Point(latitude: address.latitude, longitude: address.longitude);
    }

    String city = Storage.shared.getItem('city');

    if (city == City.Taldykorgan.toString()) {
      currentCity = City.Taldykorgan;
      return Point(latitude: 45.012569, longitude: 78.375827);
    }
    if (city == City.Semey.toString()) {
      currentCity = City.Semey;
      return Point(latitude: 50.412597, longitude: 80.249064);
    }
    if (city == City.Taraz.toString()) {
      currentCity = City.Taraz;
      return Point(latitude: 42.901015, longitude: 71.372865);
    }

    return Point(latitude: 0, longitude: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar(
          title: Text(
            'Адрес доставки',
            style: GoogleFonts.openSans(

            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack (
                children: <Widget>[
                  YandexMap(
                    onMapCreated: (YandexMapController yandexMapController) async {
                      controller = yandexMapController;

                      double zoom = (address.firstAddress == '') ? 13 : 18;
                      await controller.move(
                          point: _mapCenter(),
                          zoom: zoom,
                          animation: const MapAnimation(smooth: true, duration: 0.5)
                      );

                      final Point currentTarget = await controller.enableCameraTracking(
                          Placemark(
                            point: const Point(latitude: 0, longitude: 0),
                            iconName: 'assets/images/pin.png',
                            opacity: 0.8,
                          ),
                          cameraPositionChanged
                      );
                    },
                  ),

                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Container(
                      height: 40,
                      width: 40,
                      padding: EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),]
                      ),
                      child: FlatButton (
                        padding: EdgeInsets.all(0),
                        child: Image.asset('assets/images/cursor.png'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                        ),

                        onPressed: () async {
                          if (_permissionStatus == PermissionStatus.granted) {
                            geolocator.LocationData location = await geolocator.Location().getLocation();
                            await controller.move(
                                point: Point(latitude: location.latitude, longitude: location.longitude),
                                zoom: 18,
                                animation: const MapAnimation(smooth: true, duration: 0.5)
                            );
                          } else {
                            _requestPermission();
                          }
                        }
                      ),
                    ),
                  )
                ],
              )
            ),

            Container(
              padding: (Platform.isIOS) ? EdgeInsets.only(top: 10, bottom: 50) : EdgeInsets.only(top: 10, bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(3, 0),
                  ),]
              ),

              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 30,
                          width: 30,
                          margin: EdgeInsets.only(left: 16, right: 10),
                          child: Image.asset('assets/images/pin.png'),
                        ),
                        Expanded (
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              (address.firstAddress == "") ? "Укажите адрес" : address.firstAddress,
                              maxLines: 10,
                              style: TextStyle(
                                fontSize: 18,
                                color: (address.firstAddress == "") ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: 20,
                          width: 20,
                          margin: EdgeInsets.only(right: 10),
                          child: Center (
                            child: (_loading) ? CircularProgressIndicator() : Container(),
                          )
                        )

                      ],
                    ),
                  ),

//                  InkWell(
//                    onTap: () async {
//                      final result = await Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                            builder: (context) => DeliveryAddressDetails(address.secondAddress),
//                          )
//                      );
//                      setState(() {
//                        address.secondAddress = result;
//                      });
//                    },
//                    child: Row(
//                      children: <Widget>[
//                        Container(
//                          height: 20,
//                          width: 20,
//                          margin: EdgeInsets.only(left: 21, right: 15),
//                          child: Image.asset('assets/images/home.png'),
//                        ),
//                        Container(
//                          child: Text(
//                            (address.secondAddress == '') ? 'Подъезд, квартира и т.д' : address.secondAddress,
//                            style: TextStyle(
//                                fontSize: 18,
//                                color: (address.secondAddress == '') ? Colors.grey[500] : Colors.black
//                            ),
//                          ),
//                        )
//                      ],
//                    ),
//                  ),

                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 32,
                    margin: EdgeInsets.only(left: 16, right: 16, top: 30),
                    child: FlatButton(
                      color: Colors.blue[400],
                      textColor: Colors.white,
                      splashColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0)
                      ),

                      child: Text(
                          'Выбрать адрес',
                          style: GoogleFonts.openSans(
                              fontSize: 20,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      onPressed: () async {
                          Navigator.pop(context, this.address);
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        )
    );
  }

}
