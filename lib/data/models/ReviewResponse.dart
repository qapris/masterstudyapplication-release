import 'package:json_annotation/json_annotation.dart';

part 'ReviewResponse.g.dart';

@JsonSerializable()
class ReviewResponse {
  List<ReviewBean?> posts;
  bool total;

  ReviewResponse({required this.posts, required this.total});

  factory ReviewResponse.fromJson(Map<String, dynamic> json) => _$ReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewResponseToJson(this);
}

@JsonSerializable()
class ReviewBean {
  String user;
  String avatar_url;
  String time;
  String title;
  String content;
  num mark;

  ReviewBean({
    required this.user,
    required this.avatar_url,
    required this.time,
    required this.title,
    required this.content,
    required this.mark,
  });

  factory ReviewBean.fromJson(Map<String, dynamic> json) => _$ReviewBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewBeanToJson(this);
}
