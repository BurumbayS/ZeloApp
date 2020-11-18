import 'dart:convert';

import 'package:ZeloApp/models/Address.dart';
import 'package:ZeloApp/pages/order-comment-page.dart';
import 'package:ZeloApp/services/Storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';
import 'completed-order-page.dart';
import 'map-page.dart';
import 'package:dotted_line/dotted_line.dart';
import '../models/OrderItem.dart';
import '../models/Order.dart';
import 'dart:io' show Platform;

import '../services/Network.dart';

enum SectionType {
  order,
  address,
  contactNumber,
  comment,
  payment
}
extension SectionTypeExtension on SectionType {
  String get title {
    switch (this) {
      case SectionType.order:
        return "Ваш заказ";
      case SectionType.address:
        return "Адрес доставки";
      case SectionType.contactNumber:
        return "Контактный номер";
      case SectionType.comment:
        return "Комментарий";
      case SectionType.payment:
        return "К оплате";
    }
  }

  int get rowCount {
    switch (this) {
      case SectionType.order:
        return 2;
      case SectionType.address:
        return 1;
      case SectionType.contactNumber:
        return 1;
      case SectionType.comment:
        return 1;
      case SectionType.payment:
        return 1;
    }
  }
}

class OrderPage extends StatefulWidget{
  List<OrderItem> _orderItems;
  final int place_id;
  final Coordinates placeCoordinates;

  OrderPage(List<OrderItem> items, this.place_id, this.placeCoordinates) {
    _orderItems = items;
  }

  @override
  State<StatefulWidget> createState() {
    return new OrderPageState(_orderItems);
  }
}

class OrderPageState extends State<OrderPage> {
  int _section = 0;
  int _row = 0;
  Order _order = new Order();

  List<SectionType> _sections = [SectionType.order, SectionType.address, SectionType.contactNumber, SectionType.comment, SectionType.payment];
//  List<OrderItem> _orderItems;
  final GlobalKey<AnimatedListState> orderListKey = GlobalKey<AnimatedListState>();

  final _phoneTextFieldController = TextEditingController();
  FocusNode _focus = new FocusNode();

  bool _orderCompleted() {
    return (_order.deliveryAddress.firstAddress != '' && _order.contactPhone.length == 11);
  }

  int _itemsCount() {
    var itemsCount = 0;

    _sections.forEach((section) {
      itemsCount++;
      itemsCount += (section == SectionType.order) ? _order.orderItems.length : section.rowCount;
    });

    return itemsCount;
  }

  int _orderItemsTotal() {
    int total = 0;
    _order.orderItems.forEach((element) {
      total += element.totalPrice();
    });

    return total;
  }

  void _increaseOrderCount(OrderItem item) {
    setState(() {
      item.count++;
    });
  }

  void _decreaseOrderCount(OrderItem item) {
    setState(() {
      if (item.count == 1) {
        showDialog(context: context, builder: (_) => (Platform.isIOS) ? iosAlertDialog(item) : androidAlertDialog(item));
      } else {
        item.count--;
      }
    });
  }

  void _removeOrderItem(OrderItem item) {
    var index = _order.orderItems.indexOf(item);
    orderListKey.currentState.removeItem(
        index,
        (context, animation) => _orderItem(context, item, animation),
        duration: Duration(milliseconds: 200)
    );
    _order.orderItems.removeAt(index);

    if (_order.orderItems.length == 0) {
      Navigator.pop(context);
    }
  }

  void _placeOrder() async {
    var userData = await Storage.itemBy('user_data');
    var userJson = jsonDecode(userData);

    _order.placeID = widget.place_id;
    _order.clientID = userJson['id'];
    _order.clientName = userJson['name'];

    final http.Response response = await http.post(
        Network.api + "/order/",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(_order)
    );

    var json = jsonDecode(response.body);
    print(json);

    if (json['code'] == 0) {
      Navigator.pushReplacement(context, CupertinoPageRoute(
          builder: (context) => CompletedOrderPage(
            order: _order,
          )
      ));
    }

  }

  void _calculateDeliveryPrice(int distance) {
    var price = 0;

    if (distance < 1500) {
      price = 300;
    }
    if (distance > 1500 && distance <= 4000) {
      price = 400;
    }
    if (distance > 4000 && distance <= 6000) {
      price = 500;
    }
    if (distance > 6000 && distance <= 7500) {
      price = 600;
    }
    if (distance > 7500) {
      price = 800;
    }

    setState(() {
      _order.deliveryPrice = price;
    });

  }

  Widget iosAlertDialog(OrderItem item) {
    return CupertinoAlertDialog(
      title: Text(
        'Постойте!',
          style: GoogleFonts.capriola(
              fontSize: 18
          )
      ),
      content: Text(
        'Вы точно хотите убрать блюдо из заказа?',
          style: GoogleFonts.capriola(
              fontSize: 15
          )
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(
            'Нет',
            style: GoogleFonts.capriola(
              fontSize: 15
            )
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          }
        ),
        CupertinoDialogAction(
          child: Text(
              'Да',
              style: GoogleFonts.capriola(
                  fontSize: 15
              )
          ),
          onPressed: () {
            _removeOrderItem(item);
            Navigator.of(context, rootNavigator: true).pop();
          }
        )
      ],
    );
  }

  Widget androidAlertDialog(OrderItem item) {
    return AlertDialog(
      title: Text(
          'Постойте!'
      ),
      content: Text(
          'Вы точно хотите убрать блюдо из заказа?'
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
              'Нет'
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          }
        ),
        FlatButton(
          child: Text(
              'Да'
          ),
          onPressed: () {
            _removeOrderItem(item);
            Navigator.of(context, rootNavigator: true).pop();
          }
        )
      ],
    );
  }

  OrderPageState(List<OrderItem> items) {
    _order.orderItems = items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(
          "Оформление заказа",
          style: TextStyle(
            color: Colors.black
          ),
        ),
      ),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack (
          children: <Widget>[
            AnimatedList(
                key: orderListKey,
                initialItemCount: _itemsCount(),
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 120),
                itemBuilder: (context, i, animation) {
                  SectionType currentSection = _sections[_section];

                  if (currentSection == SectionType.order && _row > _order.orderItems.length) {
                    (_section == _sections.length - 1) ? _section = 0 : _section++;
                    currentSection = _sections[_section];
                    _row = 0;
                  } else
                  if (_row > currentSection.rowCount) {
                    (_section == _sections.length - 1) ? _section = 0 : _section++;
                    currentSection = _sections[_section];
                    _row = 0;
                  }

                  if (_row == 0) {
                    _row++;
                    return _buildListHeader(currentSection.title);
                  }

                  _row++;

                  switch (_sections[_section]) {
                    case SectionType.order:
                      return _orderItem(context, _order.orderItems[_row - 2], animation);
                    case SectionType.address:
                      return _addressItem();
                    case SectionType.contactNumber:
                      return _contactNumberItem();
                    case SectionType.comment:
                      return _commentItem();
                    case SectionType.payment:
                      return _paymentItem();
                    default:
                      return Container();
                  }
                }
            ),

            Positioned (
              bottom: (_focus.hasFocus) ? -50 : 50,
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
                  color: (_orderCompleted()) ? Colors.blue[400] : Colors.grey,
                  textColor: Colors.white,
                  splashColor: (_orderCompleted()) ? Colors.blue[700] : Colors.grey[0],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)
                  ),

                  child: Text(
                      'Оформить заказ',
                      style: GoogleFonts.openSans(
                          color: (_orderCompleted()) ? Colors.white : Colors.grey[300],
                          fontSize: 22,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  onPressed: (){
                    _placeOrder();
                  },
                ),
              ),
            )
          ],
        )
      )
    );
  }

  Widget _buildListHeader(String title) {
    return Padding (
      padding: EdgeInsets.only(top: 20),
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              title,
              style: GoogleFonts.openSans(
                  color: Colors.grey[800],
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),

          Divider()
        ],
      ),
    );
  }

  Widget _orderItem(context, OrderItem item, animation) {
    return SlideTransition (
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 16, right: 10),
                child: Text(
                  item.count.toString() + 'x',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),

              Expanded(
                  child: Text(
                    item.name,
//              maxLines: 2,
                    style: GoogleFonts.capriola(
                        fontSize: 16
                    ),
                  )
              ),

              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Text(
                  'KZT ' + item.totalPrice().toString(),
                  style: TextStyle(
                      fontSize: 18
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _decreaseOrderCount(item);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 16),
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/images/minus.png'),
                  ),
                ),

                Expanded(
                    child: Container()
                ),

                GestureDetector(
                  onTap: () {
                    _increaseOrderCount(item);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/images/plus.png'),
                  ),
                )
              ],
            ),
          ),

          Divider()
        ],
      ),

      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(animation),
    );
  }

  Widget _addressItem() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapSearchPage(_order.deliveryAddress, widget.placeCoordinates),
            )
        );

        if (result != null) {
          setState(() {
            _order.deliveryAddress = result;
          });

          _calculateDeliveryPrice(_order.deliveryAddress.distance);
        }
      },
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            child: _addressLine(),
          ),

          Divider()
        ],
      )
    );

  }

  Widget _addressLine() {
    if (_order.deliveryAddress.firstAddress == '') {
      return Text(
        'Укажите адрес',
        style: GoogleFonts.openSans(
            fontSize: 18,
            color: Colors.grey[500]
        ),
      );
    }

    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _order.deliveryAddress.firstAddress,
          maxLines: 2,
          style: GoogleFonts.openSans(
              fontSize: 18,
              color: Colors.black
          ),
        ),

        Text(
          _order.deliveryAddress.secondAddress,
          style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.grey[700]
          ),
        )
      ],
    );

  }

  Widget _contactNumberItem() {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding (
          padding: EdgeInsets.only(left: 16),
          child: TextFormField(
            controller: _phoneTextFieldController,
            focusNode: _focus,
            keyboardType: TextInputType.number,
            onChanged: (number) {
                setState(() {
                  _order.contactPhone = number;
                });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Укажите контактный номер',
              hintStyle: GoogleFonts.openSans(
                color: Colors.grey[500]
              )
            ),
            style: GoogleFonts.openSans(
              fontSize: 18
            ),
          ),
        ),

        Divider()
      ],
    );
  }

  Widget _commentItem() {
    return InkWell (
      onTap: () async {
        final result = await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderCommentPage(_order.comment),
            )
        );

        setState(() {
          _order.comment = result;
        });
      },
      child: Column (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            child: Text(
              (_order.comment == "") ? 'Ваш комментарий' : _order.comment,
              maxLines: 10,
              style: GoogleFonts.openSans(
                  fontSize: 18,
                  color: (_order.comment == "") ? Colors.grey[500] : Colors.black
              ),
            ),
          ),

          Divider()
        ],
      ),
    );
  }

  Widget _paymentItem() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Продукты',
                style: GoogleFonts.openSans(
                    fontSize: 17
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: DottedLine(
                    dashColor: Colors.grey[400],
                  ),
                )
              ),

              Text(
                'KZT ' + _orderItemsTotal().toString(),
                style: GoogleFonts.openSans(
                  fontSize: 17,
                ),
              )
            ],
          ),

          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              children: <Widget>[
                Text(
                  'Доставка',
                  style: GoogleFonts.openSans(
                      fontSize: 17
                  ),
                ),

                Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: DottedLine(
                        dashColor: Colors.grey[400],
                      ),
                    )
                ),

                Text(
                  'KZT ' + _order.deliveryPrice.toString(),
                  style: GoogleFonts.openSans(
                      fontSize: 17,
                  ),
                )
              ],
            ),
          ),

          Row(
            children: <Widget>[
              Text(
                'ВСЕГО',
                style: GoogleFonts.openSans(
                    fontSize: 17
                ),
              ),

              Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: DottedLine(
                      dashColor: Colors.grey[400],
                    ),
                  )
              ),

              Text(
                'KZT ' + (_orderItemsTotal() + _order.deliveryPrice).toString(),
                style: GoogleFonts.openSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          )
        ],
      ),
    );
  }

}