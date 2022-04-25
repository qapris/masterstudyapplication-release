// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OrdersResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdersResponse _$OrdersResponseFromJson(Map<String, dynamic> json) {
  return OrdersResponse(
    posts: (json['posts'] as List).map((e) => e == null ? null : OrderBean.fromJson(e as Map<String, dynamic>)).toList(),
    memberships: (json['memberships'] as List).map((e) => e == null ? null : MembershipBean.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

//OneTimePayment
Map<String, dynamic> _$OrdersResponseToJson(OrdersResponse instance) => <String, dynamic>{
      'orders': instance.posts,
      'memberships': instance.memberships,
    };

OrderBean _$OrderBeanFromJson(Map<String, dynamic> json) {
  return OrderBean(
    user_id: json['user_id'] as String,
    items: (json['items'] as List).map((e) => e == null ? null : ItemsBean.fromJson(e as Map<String, dynamic>)).toList(),
    date: json['date'] as String,
    status: json['status'] as String,
    payment_code: json['payment_code'] as String,
    order_key: json['order_key'] as String,
    order_total: json['_order_total'] as String,
    order_currency: json['_order_currency'] as String,
    i18n: json['i18n'] == null ? null : I18nBean.fromJson(json['i18n'] as Map<String, dynamic>),
    id: json['id'] as num,
    date_formatted: json['date_formatted'] as String,
    cart_items: (json['cart_items'] as List).map((e) => e == null ? null : Cart_itemsBean.fromJson(e as Map<String, dynamic>)).toList(),
    total: json['total'] as String,
    user: json['user'] == null ? null : UserBean.fromJson(json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$OrderBeanToJson(OrderBean instance) => <String, dynamic>{
      'user_id': instance.user_id,
      'items': instance.items,
      'date': instance.date,
      'status': instance.status,
      'payment_code': instance.payment_code,
      'order_key': instance.order_key,
      '_order_total': instance.order_total,
      '_order_currency': instance.order_currency,
      'i18n': instance.i18n,
      'id': instance.id,
      'date_formatted': instance.date_formatted,
      'cart_items': instance.cart_items,
      'total': instance.total,
      'user': instance.user,
    };

UserBean _$UserBeanFromJson(Map<String, dynamic> json) {
  return UserBean(
    id: json['id'] as num,
    login: json['login'] as String,
    avatar: json['avatar'] as String,
    avatar_url: json['avatar_url'] as String,
    email: json['email'] as String,
    url: json['url'] as String,
  );
}

Map<String, dynamic> _$UserBeanToJson(UserBean instance) => <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'avatar': instance.avatar,
      'avatar_url': instance.avatar_url,
      'email': instance.email,
      'url': instance.url,
    };

Cart_itemsBean _$Cart_itemsBeanFromJson(Map<String, dynamic> json) {
  return Cart_itemsBean(
    cart_item_id: json['cart_item_id'] as int,
    title: json['title'] as String,
    image: json['image'] as String,
    status: json['status'] as String,
    price: json['price'],
    terms: (json['terms'] as List).map((e) => e as String).toList(),
    price_formatted: json['price_formatted'] as String,
    image_url: json['image_url'] as String,
  );
}

Map<String, dynamic> _$Cart_itemsBeanToJson(Cart_itemsBean instance) => <String, dynamic>{
      'cart_item_id': instance.cart_item_id,
      'title': instance.title,
      'image': instance.image,
      'image_url': instance.image_url,
      'price': instance.price,
      'terms': instance.terms,
      'price_formatted': instance.price_formatted,
    };

I18nBean _$I18nBeanFromJson(Map<String, dynamic> json) {
  return I18nBean(
    order_key: json['order_key'] as String,
    date: json['date'] as String,
    status: json['status'] as String,
    pending: json['pending'] as String,
    processing: json['processing'] as String,
    failed: json['failed'] as String,
    on_hold: json['on-hold'] as String,
    refunded: json['refunded'] as String,
    completed: json['completed'] as String,
    cancelled: json['cancelled'] as String,
    user: json['user'] as String,
    order_items: json['order_items'] as String,
    course_name: json['course_name'] as String,
    course_price: json['course_price'] as String,
    total: json['total'] as String,
  );
}

Map<String, dynamic> _$I18nBeanToJson(I18nBean instance) => <String, dynamic>{
      'order_key': instance.order_key,
      'date': instance.date,
      'status': instance.status,
      'pending': instance.pending,
      'processing': instance.processing,
      'failed': instance.failed,
      'on-hold': instance.on_hold,
      'refunded': instance.refunded,
      'completed': instance.completed,
      'cancelled': instance.cancelled,
      'user': instance.user,
      'order_items': instance.order_items,
      'course_name': instance.course_name,
      'course_price': instance.course_price,
      'total': instance.total,
    };

ItemsBean _$ItemsBeanFromJson(Map<String, dynamic> json) {
  return ItemsBean(
    item_id: json['item_id'] as String,
    price: json['price'] as String,
  );
}

Map<String, dynamic> _$ItemsBeanToJson(ItemsBean instance) => <String, dynamic>{
      'item_id': instance.item_id,
      'price': instance.price,
    };

//Memberships
MembershipBean _$MembershipBeanFromJson(Map<String, dynamic> json) {
  return MembershipBean(
    ID: json['ID'] as String,
    id: json['id'] as String,
    subscription_id: json['subscription_id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    confirmation: json['confirmation'] as String,
    expiration_number: json['expiration_number'] as String,
    expiration_period: json['expiration_period'] as String,
    initial_payment: json['initial_payment'] as num,
    billing_amount: json['billing_amount'] as num,
    cycle_number: json['cycle_number'] as String,
    cycle_period: json['cycle_period'] as String,
    billing_limit: json['billing_limit'] as String,
    trial_amount: json['trial_amount'] as num,
    trial_limit: json['trial_limit'] as String,
    code_id: json['code_id'] as String,
    startdate: json['startdate'] as String,
    enddate: json['enddate'] as String,
    course_number: json['course_number'] as String,
    used_quotas: json['used_quotas'] as num,
    quotas_left: json['quotas_left'] as num,
    button: json['button'] == null ? null : ButtonBean.fromJson(json['button'] as Map<String, dynamic>),
    features: json['features'] as String,
    status: json['status'] as String,
  );
}

Map<String, dynamic> _$MembershipBeanToJson(MembershipBean instance) => <String, dynamic>{
      'ID': instance.ID,
      'id': instance.id,
      'subscription_id': instance.subscription_id,
      'name': instance.name,
      'description': instance.description,
      'confirmation': instance.confirmation,
      'expiration_number': instance.expiration_number,
      'expiration_period': instance.expiration_period,
      'initial_payment': instance.initial_payment,
      'billing_amount': instance.billing_amount,
      'cycle_number': instance.cycle_number,
      'cycle_period': instance.cycle_period,
      'billing_limit': instance.billing_limit,
      'trial_amount': instance.trial_amount,
      'trial_limit': instance.trial_limit,
      'code_id': instance.code_id,
      'startdate': instance.startdate,
      'enddate': instance.enddate,
      'course_number': instance.course_number,
      'features': instance.features,
      'used_quotas': instance.used_quotas,
      'quotas_left': instance.quotas_left,
      'button': instance.button,
      'status': instance.status,
    };

ButtonBean _$ButtonBeanFromJson(Map<String, dynamic> json) {
  return ButtonBean(
    text: json['text'] as String,
    url: json['url'] as String,
  );
}

Map<String, dynamic> _$ButtonBeanToJson(ButtonBean instance) => <String, dynamic>{
      'text': instance.text,
      'url': instance.url,
    };
