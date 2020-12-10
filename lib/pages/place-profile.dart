import 'dart:convert';

import 'package:ZeloApp/models/Address.dart';
import 'package:ZeloApp/pages/auth/auth-page.dart';
import 'package:ZeloApp/services/Network.dart';
import 'package:ZeloApp/pages/order-page.dart';
import 'package:ZeloApp/services/Storage.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stretchy_header/stretchy_header.dart';
import 'package:flutter/cupertino.dart';
import '../models/Place.dart';
import '../models/MenuItem.dart';
import '../models/OrderItem.dart';
import 'package:http/http.dart' as http;

class PlaceProfile extends StatefulWidget {
  Place _place;

  PlaceProfile(Place place) {
    _place = place;
  }

  @override
  State<StatefulWidget> createState() {
    return new PlaceProfileState(_place);
  }
}

class PlaceProfileState extends State<PlaceProfile>{
  int _selectedItemsCount = 0;
  String _selectedCategory = "";
  Map<int, OrderItem> _orderItems = new Map();
  Place _placeInfo;
  Map<String, List<MenuItem>> _categorizedMenuItems = new Map();

  PlaceProfileState(Place place) {
    _placeInfo = place;
  }

  @override
  void initState() {
    super.initState();

    loadMenuItems();
  }

  void loadMenuItems() async {
    var placeID = _placeInfo.id;
    String url = Network.api + '/menuItems/$placeID';
    var response = await http.get(url);

    var itemsJson = json.decode(response.body).cast<Map<String, dynamic>>();

    var menuItemsList = new List<MenuItem>();

    itemsJson.forEach((element) {
      var menuItem = MenuItem.fromJson(element);
      menuItemsList.add(menuItem);
    });

    categorizeMenu(menuItemsList);
  }

  void categorizeMenu(menuItems) {

    for (var category in _placeInfo.categories.values) {
      _categorizedMenuItems[category] = new List();
    }

    for (var item in menuItems) {
      var category = item.category;
      _categorizedMenuItems[category].add(item);
    }

    setState(() {
      _selectedCategory = _placeInfo.categories["1"];
    });
  }

  int getCategoryItemsCount(category){
    return (_categorizedMenuItems[category] != null) ? _categorizedMenuItems[category].length : 0;
  }

  MenuItem _itemAtIndex(index){
    return _categorizedMenuItems[_selectedCategory][index];
  }

  void _addToOrder(itemIndex) {
    setState(() {
      var menuItemToAdd = _itemAtIndex(itemIndex);
      var newOrderItem = OrderItem.fromMenuItem(menuItemToAdd);
      _orderItems[menuItemToAdd.id] = newOrderItem;

      _selectedItemsCount++;
    });
  }

  void _removeFromOrder(itemIndex) {
    setState(() {
      _orderItems[_itemAtIndex(itemIndex).id] = null;
      _selectedItemsCount--;
    });
  }

  void _increaseOrderCount(itemIndex) {
    setState(() {
      var orderItem = _orderItems[_itemAtIndex(itemIndex).id];
      orderItem.count++;
    });
  }

  void _decreaseOrderCount(itemIndex) {
    setState(() {
      var orderItem = _orderItems[_itemAtIndex(itemIndex).id];
      orderItem.count--;
      if (orderItem.count == 0) {
        _orderItems[_itemAtIndex(itemIndex).id] = null;
        _selectedItemsCount--;
      }
    });
  }

  int getOrderItemPrice(MenuItem item) {
    var orderItem = _orderItems[item.id];
    if (orderItem != null) {
      return orderItem.totalPrice();
    }

    return 0;
  }

  bool _isInOrder(MenuItem item) {
    return _orderItems[item.id] != null;
  }

  double _heightOfItem(itemIndex) {
    if (_orderItems[_itemAtIndex(itemIndex).id] != null) { return 50; }

    return 0;
  }

  int _getItemOrderCount(itemIndex) {
    var item = _orderItems[_itemAtIndex(itemIndex).id];
    if (item != null) {
      return item.count;
    } else {
      return 0;
    }
  }

  bool _shouldShowOrderTotal() {
    return _selectedItemsCount > 0;
  }

  bool _shouldAddBottomPadding(index) {
    if (index == _categorizedMenuItems[_selectedCategory].length - 1 && _selectedItemsCount > 0) {
      return true;
    }

    return false;
  }

  String _getOrderTotalInfo() {
    int totalCount = 0;
    int totalPrice = 0;

    _orderItems.forEach((key, value) {
      if (value != null) {
        totalCount += value.count;
        totalPrice += value.totalPrice();
      }
    });

    return '$totalCount  за  $totalPrice KZT';
  }

  void goToOrderPage() {
    List<OrderItem> selectedOrderItems = new List();
    
    _orderItems.forEach((key, value) { 
      if (value != null) {
        selectedOrderItems.add(value);
      }
    });

    Navigator.of(context).push(
        CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => OrderPage(selectedOrderItems, _placeInfo.id, Coordinates(_placeInfo.latitude, _placeInfo.longitude))
        )
    );
  }

  void orderItem(bool inOrder, int itemIndex, MenuItem item) async {
    bool _isAuthenticated = await isAuthenticated();

    if (!_isAuthenticated) {
      showDialog(context: context, builder: (_) => CustomAlertDialog.shared.dialog("Хотите зарегестрироваться?\n", "Для заказа блюда вам необходимо зарегестрироваться", false, context, () {
          Navigator.pop(context);
          Navigator.of(context).push(
              CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => AuthPage()
              )
          );
        })
      );
    } else {
      if (_placeInfo.notWorking) {
        showDialog(context: context, builder: (_) => CustomAlertDialog.shared.dialog("Простите\n", "Заведение не принимает заказов в данное время", true, context, () {
          Navigator.pop(context);
        }));
      } else
      if (item.stopped) {
        showDialog(context: context, builder: (_) => CustomAlertDialog.shared.dialog("Простите\n", "Данное блюдо не может быть приготовлено в данное время", true, context, () {
          Navigator.pop(context);
        }));
      } else {
        (inOrder) ? _removeFromOrder(itemIndex) : _addToOrder(itemIndex);
        Navigator.pop(context);
      }
    }

  }

  Future<bool> isAuthenticated() async {
    String value = await Storage.itemBy('token');
    if (value != null) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: StretchyHeader.listViewBuilder(
              headerData: HeaderData(
                  headerHeight: 250,
                  header: Image.network(
                    Network.host + _placeInfo.wallpaper,
                    fit: BoxFit.cover,
                  ),
                  highlightHeaderAlignment: HighlightHeaderAlignment.top,
                  highlightHeader: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: <Widget>[

                          Container(
                              margin: EdgeInsets.only(top: 45, left: 15),
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: Colors.grey[200].withOpacity(0.5)
                              ),

                              child: Image.asset('assets/images/arrow.png')
                          ),

                          Expanded(
                            child: Container(

                            ),
                          ),

//                          Container(
//                            margin: EdgeInsets.only(right: 15, top: 45),
//                            height: 40,
//                            width: 40,
//                            decoration: BoxDecoration(
//                                borderRadius: BorderRadius.all(Radius.circular(20)),
//                                color: Colors.grey[200].withOpacity(0.5)
//                            ),
//
//                            child: Icon(
//                                Icons.search
//                            ),
//                          )
                        ],
                      ),
                    ),
                  )
              ),
              itemCount: getCategoryItemsCount(_selectedCategory) + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader();
                }

                if (index == 1) {
                  return _buildCategoryRow();
                }

                return _buildMenuItem(context, index - 2, _categorizedMenuItems[_selectedCategory][index - 2]);
              },
            ),
          ),

          AnimatedPositioned(
            bottom: _shouldShowOrderTotal() ? 50 : -50,
            duration: Duration(milliseconds: 200),
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
                splashColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)
                ),

                child: Text(
                    _getOrderTotalInfo(),
                    style: GoogleFonts.openSans(
                      fontSize: 22,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold
                    )
                ),
                onPressed: () {
                  goToOrderPage();
                },
              ),
            ),
          )

        ],
      )
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              _placeInfo.name,
              style: GoogleFonts.capriola(
                color: Colors.black,
                fontSize: 24,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
              )
          ),

          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
                _placeInfo.description,
                style: GoogleFonts.capriola(
                  color: Colors.grey[500],
                  fontSize: 15,
                  decoration: TextDecoration.none,
                )
            ),
          )

        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            width: 1.0,
            color: Colors.grey[200]
          ))
      ),
      child: ListView.builder(
          itemCount: _placeInfo.categories.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10.0),
          itemBuilder: (context, i) {
            var category = _placeInfo.categories[(i+1).toString()];
            return _buildCategory(category);
          }
      ),
    );
  }
  Widget _buildCategory(String category) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color: (_selectedCategory == category) ? Colors.blue[300] : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        child: Text(
          category,
          style: GoogleFonts.openSans(
              fontSize: 16,
              color: (_selectedCategory == category) ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(context, itemIndex, MenuItem menuItem) {
    return InkWell(
        onTap: () {
          _dishInfoModal(context, itemIndex, _isInOrder(menuItem));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container (
              child: Row(
                children: <Widget>[
                  Expanded(

                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            menuItem.name,
                            maxLines: 1,
                            style: GoogleFonts.capriola(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black
                            ),
                          ),

                          Text(
                            menuItem.description,
                            maxLines: 2,
                          ),

                          Text(
                            menuItem.price.toString() + ' KZT',
                            style: GoogleFonts.capriola(
                                color: Colors.blue[300],
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                    ),

                  ),

                  Container(
                    width: 100,
                    height: 80,
                    margin: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(Network.host + menuItem.image),
                          fit: BoxFit.cover
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),

                  ),
                ],
              ),
            ),

            AnimatedContainer(
              margin: EdgeInsets.only(left: 10, right: 10),
              duration: Duration(milliseconds: 300),
              height: _heightOfItem(itemIndex),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      _decreaseOrderCount(itemIndex);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/images/minus.png'),
                    ),
                  ),

                  Container(
                    width: 50,
                    height: 30,
                    child: Text(
                      _getItemOrderCount(itemIndex).toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                        color: Colors.grey[700],
                        fontSize: 20,
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _increaseOrderCount(itemIndex);
                      },
                      child:  Container(
                        height: 30,
                        width: 30,
                        alignment: Alignment.centerLeft,
                        child: Image.asset('assets/images/plus.png'),
                      ),
                    ),
                  ),

                  Text(
                    getOrderItemPrice(menuItem).toString(),
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                  )
                ],
              ),
            ),

            Container(
              height: 1,
              margin: _shouldAddBottomPadding(itemIndex) ? EdgeInsets.only(left: 10, right: 5, bottom: 120) : EdgeInsets.only(left: 10, right: 5, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(0.2)),
              ),
            )
          ],
        ),
    );
  }

  void _dishInfoModal(context, itemIndex, bool inOrder) {
    MenuItem selectedItem = _categorizedMenuItems[_selectedCategory][itemIndex];

    showModalBottomSheet(context: context, builder: (BuildContext bc) {
      return Container(
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 5),
              width: double.infinity,
              alignment: Alignment.center,
              child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
              ),
            ),

            Container(
              width: double.infinity,
              height: 200,
              margin: EdgeInsets.only(right: 10, top: 10, left: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(Network.host + selectedItem.image),
                    fit: BoxFit.cover
                ),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),

            ),

            Padding(
              padding: EdgeInsets.only(top: 20, left: 10),
              child: Text(
                selectedItem.name,
                 style: GoogleFonts.capriola(
                    color: Colors.black,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                 )
              )
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  selectedItem.description,
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
              width: double.infinity,
              height: 50,
              child: FlatButton(
                color: (inOrder) ? Colors.red : Colors.blue,
                textColor: Colors.white,
                splashColor: (inOrder) ? Colors.red[600] : Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Text(
                    (inOrder) ? 'Убрать из заказа' : 'Заказать',
                    style: GoogleFonts.capriola(
                      fontSize: 18,
                      decoration: TextDecoration.none,
                    )
                ),
                onPressed: () {
                  orderItem(inOrder, itemIndex, selectedItem);
                },
              ),

            )

          ],
        ),
      );
    });
  }

}