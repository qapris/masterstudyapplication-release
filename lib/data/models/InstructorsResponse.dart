import 'package:json_annotation/json_annotation.dart';

part 'InstructorsResponse.g.dart';

@JsonSerializable()
class InstructorsResponse {
  num page;
  List<InstructorBean?> data;
  num total_pages;

  InstructorsResponse({required this.page, required this.data, required this.total_pages});

  factory InstructorsResponse.fromJson(Map<String, dynamic> json) => _$InstructorsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InstructorsResponseToJson(this);
}

@JsonSerializable()
class InstructorBean {
  num id;
  String login;
  String avatar;
  String avatar_url;
  String email;
  String url;
  MetaBean? meta;
  RatingBean? rating;
  String profile_url;

  InstructorBean({
    required this.id,
    required this.login,
    required this.avatar,
    required this.avatar_url,
    required this.email,
    required this.url,
    required this.meta,
    required this.rating,
    required this.profile_url,
  });

  factory InstructorBean.fromJson(Map<String, dynamic> json) => _$InstructorBeanFromJson(json);

  Map<String, dynamic> toJson() => _$InstructorBeanToJson(this);
}

@JsonSerializable()
class RatingBean {
  num total;
  num average;
  num marks_num;
  String total_marks;
  num percent;

  RatingBean({
    required this.total,
    required this.average,
    required this.marks_num,
    required this.total_marks,
    required this.percent,
  });

  factory RatingBean.fromJson(Map<String, dynamic> json) => _$RatingBeanFromJson(json);

  Map<String, dynamic> toJson() => _$RatingBeanToJson(this);
}

@JsonSerializable()
class MetaBean {
  String? facebook;
  String twitter;
  String instagram;
  @JsonKey(name: "google-plus")
  String google_plus;
  String? position;
  String description;
  String first_name;
  String last_name;

  MetaBean({
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.google_plus,
    required this.position,
    required this.description,
    required this.first_name,
    required this.last_name,
  });

  factory MetaBean.fromJson(Map<String, dynamic> json) => _$MetaBeanFromJson(json);

  Map<String, dynamic> toJson() => _$MetaBeanToJson(this);
}
