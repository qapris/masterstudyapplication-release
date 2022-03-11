import 'package:json_annotation/json_annotation.dart';

part 'OrdersResponse.g.dart';

class OrdersResponse {
  final List<OrderBean> orders;

  OrdersResponse(
    this.orders,
  );

  OrdersResponse.fromJsonArray(List json) : orders = json.map((i) => new OrderBean.fromJson(i)).toList();
}

@JsonSerializable()
class OrderBean {
  String user_id;
  List<ItemsBean?> items;
  String date;
  String status;
  String payment_code;
  String order_key;
  @JsonKey(name: "_order_total")
  String order_total;
  @JsonKey(name: "_order_currency")
  String order_currency;
  I18nBean? i18n;
  num id;
  String date_formatted;
  List<Cart_itemsBean?> cart_items;
  String total;
  UserBean? user;

  OrderBean(
      {required this.user_id,
      required this.items,
      required this.date,
      required this.status,
      required this.payment_code,
      required this.order_key,
      required this.order_total,
      required this.order_currency,
      required this.i18n,
      required this.id,
      required this.date_formatted,
      required this.cart_items,
      required this.total,
      required this.user});

  factory OrderBean.fromJson(Map<String, dynamic> json) => _$OrderBeanFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBeanToJson(this);
}

@JsonSerializable()
class UserBean {
  num id;
  String login;
  String avatar;
  String avatar_url;
  String email;
  String url;

  UserBean({required this.id, required this.login, required this.avatar, required this.avatar_url, required this.email, required this.url});

  factory UserBean.fromJson(Map<String, dynamic> json) => _$UserBeanFromJson(json);

  Map<String, dynamic> toJson() => _$UserBeanToJson(this);
}

@JsonSerializable()
class Cart_itemsBean {
  int cart_item_id;
  String title;
  String image;
  String image_url;
  String price;
  List<String?> terms;
  String price_formatted;

  Cart_itemsBean({
    required this.cart_item_id,
    required this.title,
    required this.image,
    required this.price,
    required this.terms,
    required this.price_formatted,
    required this.image_url,
  });

  factory Cart_itemsBean.fromJson(Map<String, dynamic> json) => _$Cart_itemsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$Cart_itemsBeanToJson(this);
}

@JsonSerializable()
class I18nBean {
  String order_key;
  String date;
  String status;
  String pending;
  String processing;
  String failed;
  @JsonKey(name: "on-hold")
  String on_hold;
  String refunded;
  String completed;
  String cancelled;
  String user;
  String order_items;
  String course_name;
  String course_price;
  String total;

  I18nBean(
      {required this.order_key,
      required this.date,
      required this.status,
      required this.pending,
      required this.processing,
      required this.failed,
      required this.on_hold,
      required this.refunded,
      required this.completed,
      required this.cancelled,
      required this.user,
      required this.order_items,
      required this.course_name,
      required this.course_price,
      required this.total});

  factory I18nBean.fromJson(Map<String, dynamic> json) => _$I18nBeanFromJson(json);

  Map<String, dynamic> toJson() => _$I18nBeanToJson(this);
}

@JsonSerializable()
class ItemsBean {
  String item_id;
  String price;

  ItemsBean({required this.item_id, required this.price});

  factory ItemsBean.fromJson(Map<String, dynamic> json) => _$ItemsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ItemsBeanToJson(this);
}
