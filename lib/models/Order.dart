import 'package:ZeloApp/models/Address.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'OrderItem.dart';
import 'Place.dart';

part 'Order.g.dart';

enum OrderStatus {
  NEW,
  COOKING,
  DELIVERING,
  COMPLETED
}

@JsonSerializable()

class Order {
  int id;
  @JsonKey(name: 'place_id')
  int placeID;
  Place place;
  @JsonKey(name: 'status')
  OrderStatus orderStatus;
  @JsonKey(name: 'order_items')
  List<OrderItem> orderItems;
  String promoCode;
  @JsonKey(name: 'delivery_price')
  int deliveryPrice;
  @JsonKey(name: 'client_id')
  int clientID;
  @JsonKey(name: 'client_name')
  String clientName;
  int price;
  @JsonKey(name: 'delivery_address')
  Address deliveryAddress;
  @JsonKey(name: 'contact_phone')
  String contactPhone;
  String comment;
  String date;
  String time;

  Order() {
    orderStatus = OrderStatus.NEW;
    orderItems = new List();
    deliveryAddress = new Address();
    deliveryPrice = 0;
    contactPhone = '';
    comment = '';
  }

  String formatedDate() {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime dateTime = dateFormat.parse(date);
    String formattedDate = DateFormat('dd.MM.yyyy').format(dateTime);

    return formattedDate;
  }

  int total() {
    int total = 0;

    for (var i = 0; i < orderItems.length; i++) {
      total += orderItems[i].price * orderItems[i].count;
    }

    return total;
  }

  int totalWithDelivery() {
    return total() + deliveryPrice;
  }

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}