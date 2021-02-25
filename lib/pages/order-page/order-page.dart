import 'dart:convert';

import 'package:ZeloApp/models/Address.dart';
import 'package:ZeloApp/models/PromoCode.dart';
import 'package:ZeloApp/pages/order-page/order-comment-page.dart';
import 'package:ZeloApp/utils/alertDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'completed-order-page.dart';
import 'map-page.dart';
import 'package:dotted_line/dotted_line.dart';
import '../../models/OrderItem.dart';
import '../../models/Order.dart';
import 'dart:io' show Platform;

import '../../services/Network.dart';

enum SectionType {
  order,
  address,
  contactNumber,
  comment,
  promocode,
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
      case SectionType.promocode:
        return "Промокод";
      case SectionType.payment:
        return "К оплате";
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

  Order _order = new Order();
  PromoCode _promoCode;

  double confirmOrderBtnBottomMargin = 50;

  bool _loading = false;

  List<SectionType> _sections = [SectionType.order, SectionType.address, SectionType.contactNumber, SectionType.comment, SectionType.promocode, SectionType.payment];

  final GlobalKey<AnimatedListState> orderListKey = GlobalKey<AnimatedListState>();

//  final _phoneTextFieldController = TextEditingController();
  FocusNode _focusOnPhone = new FocusNode();
  FocusNode _focusOnPromoCode = new FocusNode();

  initState() {
      _focusOnPhone.addListener(() async {
        if (!_focusOnPhone.hasFocus && !_focusOnPromoCode.hasFocus) {
          await Future.delayed(Duration(milliseconds: 100));

          setState(() {
            confirmOrderBtnBottomMargin = 50;
          });
        } else {
          setState(() {
            confirmOrderBtnBottomMargin = -50;
          });
        }
      });

      _focusOnPromoCode.addListener(() async {
        if (!_focusOnPromoCode.hasFocus && !_focusOnPhone.hasFocus) {
          await Future.delayed(Duration(milliseconds: 100));

          setState(() {
            confirmOrderBtnBottomMargin = 50;
          });
        } else {
          setState(() {
            confirmOrderBtnBottomMargin = -50;
          });
        }
      });
  }

  bool _orderCompleted() {
    return (_order.deliveryAddress.firstAddress != '' && _order.contactPhone.length == 11);
  }

  int _itemsCount() {
    var itemsCount = 0;

    _sections.forEach((section) {
      itemsCount++;
      itemsCount += (section == SectionType.order) ? _order.orderItems.length : 1;
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
        showDialog(context: context, builder: (_) =>  CustomAlertDialog.shared.dialog("Постойте!", 'Вы точно хотите убрать блюдо из заказа?', false, context, () {
          _removeOrderItem(item);
        }));
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
    if (!_orderCompleted()) { return; }

    setState(() {
      _loading = true;
    });

    _order.placeID = widget.place_id;

    final http.Response response = await http.post(
        Network.shared.api + "/order/",
        headers: Network.shared.headers(),
        body: jsonEncode(_order)
    );

    setState(() {
      _loading = true;
    });

    var json = jsonDecode(response.body);
    print(json);

    if (json['code'] == 0) {
      Order placedOrder = Order.fromJson(json['order']);
      Navigator.pushReplacement(context, CupertinoPageRoute(
          builder: (context) => CompletedOrderPage(
            order: placedOrder,
          )
      ));
    } else {
      showDialog(context: context, builder: (_) =>  CustomAlertDialog.shared.dialog("Простите", json["error"], true, context, () {
        Navigator.pop(context);
      }));
    }

  }

  void _activatePromoCode(String code) async {
    setState(() {
      _loading = true;
    });

    var requestJson = { "promoCode" : code };

    final http.Response response = await http.post(
        Network.shared.api + "/activatePromoCode/",
        headers: Network.shared.headers(),
        body: jsonEncode(requestJson)
    );

    setState(() {
      _loading = false;
    });

    var responseJson = jsonDecode(response.body);

    if (responseJson['code'] == 0) {
      setState(() {
        _promoCode = PromoCode(responseJson['promoCode']);
        _order.promoCode = _promoCode.code;
      });
    } else {
      showDialog(context: context, builder: (_) =>  CustomAlertDialog.shared.dialog("Простите", responseJson["error"], true, context, () {
        setState(() {
          _promoCode = null;
        });
      }));
    }
  }

  String _promoCodeValue() {
    switch (_promoCode.type) {
      case PromoCodeType.FREEDELIVERY:
        return _order.deliveryPrice.toString();
      case PromoCodeType.BONUS:
        return _promoCode.bonus.toString();
      case PromoCodeType.SALE:
        return _promoCode.sale.toString() + "%";
      default:
        return "";
    }
  }

  int _orderTotalWithPromoCode() {
    var promoCodeSum = 0;

    switch (_promoCode.type) {
      case PromoCodeType.FREEDELIVERY:
        promoCodeSum = _order.deliveryPrice;
        break;
      case PromoCodeType.BONUS:
        promoCodeSum = _promoCode.bonus;
        break;
      case PromoCodeType.SALE:
        promoCodeSum = (_order.totalWithDelivery() * (_promoCode.sale / 100)).toInt();
        break;
    }

    _order.totalWithPromoCode = _order.totalWithDelivery() - promoCodeSum;

    return _order.totalWithPromoCode;
  }

  void _calculateDeliveryPrice(int distance) {
    var price = 0;

    if (distance < 1000) {
      price = 300;
    }
    if (distance > 1000 && distance <= 4000) {
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

  Widget _itemAtIndex(index) {

    int restIndex = index - (_order.orderItems.length + 1);
    int sectionIndex = (restIndex ~/ 2) + 1;

      if (restIndex % 2 == 0) {
        return _buildListHeader(_sections[sectionIndex].title);
      } else {
        switch (_sections[sectionIndex]) {
          case SectionType.address:
            return _addressItem();
          case SectionType.contactNumber:
            return _contactNumberItem();
          case SectionType.comment:
            return _commentItem();
          case SectionType.promocode:
            return _promoCodeItem();
          case SectionType.payment:
            return _paymentItem();
          default:
            return Container();
        }
      }
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

      body: Stack (
        children: <Widget>[
          GestureDetector(
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
                        if (i <= _order.orderItems.length) {
                          if (i == 0) {
                            return _buildListHeader(SectionType.order.title);
                          } else {
                            return _orderItem(context, _order.orderItems[i-1], animation);
                          }
                        } else {
                          return _itemAtIndex(i);
                        }
                      }
                  ),

                  Positioned (
                    bottom: confirmOrderBtnBottomMargin,
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
          ),

          (_loading) ? Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height ,
              color: Colors.black.withOpacity(0.05),
              child: Center (
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
              ),
            )
          ) : Container()
        ],
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
//            controller: _phoneTextFieldController,
            focusNode: _focusOnPhone,
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

  Widget _promoCodeItem() {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding (
          padding: EdgeInsets.only(left: 16),
          child: TextFormField(
//            controller: _phoneTextFieldController,
            focusNode: _focusOnPromoCode,
            onFieldSubmitted: (text)  async {
              _activatePromoCode(text);
            },
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Введите промокод',
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
                _order.getTotal().toString(),
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
                  _order.deliveryPrice.toString(),
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
                _order.totalWithDelivery().toString(),
                style: GoogleFonts.openSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),

          (_promoCode != null) ? _promoCodePaymentItem() : Container()
        ],
      ),
    );
  }

  Widget _promoCodePaymentItem() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DottedLine(
            dashColor: Colors.black,
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Промокод',
                  style: GoogleFonts.openSans(
                    fontSize: 17,
                    color: Colors.blue
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
                  '- ' + _promoCodeValue(),
                  style: GoogleFonts.openSans(
                      fontSize: 17,
                      color: Colors.blue
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'ИТОГО',
                  style: GoogleFonts.openSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
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
                  _orderTotalWithPromoCode().toString(),
                  style: GoogleFonts.openSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}