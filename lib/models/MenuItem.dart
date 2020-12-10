import 'package:json_annotation/json_annotation.dart';

part 'MenuItem.g.dart';

@JsonSerializable()

class MenuItem {
  int id;
  String name;
  String description;
  String category;
  int price;
  @JsonKey(name: 'place_id')
  int placeID;
  String image;
  bool stopped;

  MenuItem(this.id, this.name, this.description, this.price, this.placeID, this.image, this.stopped);

  factory MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}