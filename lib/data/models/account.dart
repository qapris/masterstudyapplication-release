import 'package:json_annotation/json_annotation.dart';

import 'InstructorsResponse.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  num id;
  String login;
  dynamic avatar;
  String? avatar_url;
  String email;
  String url;
  List<dynamic> roles;
  MetaBean? meta;
  RatingBean? rating;
  String profile_url;

  Account(
      {required this.id,
      required this.login,
        this.avatar,
      required this.avatar_url,
      required this.email,
      required this.url,
      required this.roles,
      required this.meta,
      required this.rating,
      required this.profile_url});

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable()
class RatingBean {
  num total;
  num average;
  num marks_num;
  String total_marks;
  num percent;

  RatingBean({required this.total, required this.average, required this.marks_num, required this.total_marks, required this.percent});

  factory RatingBean.fromJson(Map<String, dynamic> json) => _$RatingBeanFromJson(json);

  Map<String, dynamic> toJson() => _$RatingBeanToJson(this);
}
