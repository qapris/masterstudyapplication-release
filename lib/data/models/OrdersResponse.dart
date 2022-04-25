import 'package:json_annotation/json_annotation.dart';

part 'OrdersResponse.g.dart';

//MainClass
class OrdersResponse {
  final List<OrderBean?> posts;
  final List<MembershipBean?> memberships;

  OrdersResponse({
    required this.posts,
    required this.memberships,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) => _$OrdersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersResponseToJson(this);
}

//OneTimePayment
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
  String status;
  dynamic price;
  List<String?> terms;
  String price_formatted;

  Cart_itemsBean({
    required this.cart_item_id,
    required this.title,
    required this.image,
    required this.status,
    this.price,
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

//Membership
@JsonSerializable()
class MembershipBean {
  String ID;
  String id;
  String subscription_id;
  String name;
  String description;
  String confirmation;
  String expiration_number;
  String expiration_period;
  num initial_payment;
  num billing_amount;
  String cycle_number;
  String cycle_period;
  String billing_limit;
  num trial_amount;
  String trial_limit;
  String code_id;
  String startdate;
  String enddate;
  String course_number;
  String features;
  num used_quotas;
  num quotas_left;
  ButtonBean? button;
  String status;

  MembershipBean(
      {required this.ID,
      required this.id,
      required this.subscription_id,
      required this.name,
      required this.description,
      required this.confirmation,
      required this.expiration_number,
      required this.expiration_period,
      required this.initial_payment,
      required this.billing_amount,
      required this.cycle_number,
      required this.cycle_period,
      required this.billing_limit,
      required this.trial_amount,
      required this.trial_limit,
      required this.code_id,
      required this.startdate,
      required this.enddate,
      required this.course_number,
      required this.used_quotas,
      required this.quotas_left,
      required this.button,
      required this.features,
      required this.status});

  factory MembershipBean.fromJson(Map<String, dynamic> json) => _$MembershipBeanFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipBeanToJson(this);
}

@JsonSerializable()
class ButtonBean {
  String text;
  String url;

  ButtonBean({required this.text, required this.url});

  factory ButtonBean.fromJson(Map<String, dynamic> json) => _$ButtonBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ButtonBeanToJson(this);
}
