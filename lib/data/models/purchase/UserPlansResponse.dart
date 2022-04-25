import 'package:json_annotation/json_annotation.dart';

part 'UserPlansResponse.g.dart';

//UserPlansModel
class UserPlansResponse {
  final List<UserPlansBean?> subscriptions;
  final bool other_subscriptions;

  UserPlansResponse({
    required this.subscriptions,
    required this.other_subscriptions,
  });

  factory UserPlansResponse.fromJson(Map<String, dynamic> json) => _$UserPlansResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserPlansResponseToJson(this);
}

@JsonSerializable()
class UserPlansBean {
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

  UserPlansBean(
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
      required this.features});

  factory UserPlansBean.fromJson(Map<String, dynamic> json) => _$UserPlansBeanFromJson(json);

  Map<String, dynamic> toJson() => _$UserPlansBeanToJson(this);
}

@JsonSerializable()
class ButtonBean {
  String text;
  String url;

  ButtonBean({required this.text, required this.url});

  factory ButtonBean.fromJson(Map<String, dynamic> json) => _$ButtonBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ButtonBeanToJson(this);
}


