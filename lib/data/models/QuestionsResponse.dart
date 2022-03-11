import 'package:json_annotation/json_annotation.dart';

part 'QuestionsResponse.g.dart';

@JsonSerializable()
class QuestionsResponse {
  List<QuestionBean?> posts;

  QuestionsResponse({required this.posts});

  factory QuestionsResponse.fromJson(Map<String, dynamic> json) => _$QuestionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionsResponseToJson(this);
}

@JsonSerializable()
class QuestionBean {
  String comment_ID;
  String content;
  QuestionAuthorBean? author;
  String datetime;
  String? replies_count;
  List<ReplyBean?> replies;

  QuestionBean({
    required this.comment_ID,
    required this.content,
    required this.author,
    required this.datetime,
    required this.replies_count,
    required this.replies,
  });

  factory QuestionBean.fromJson(Map<String, dynamic> json) => _$QuestionBeanFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionBeanToJson(this);
}

@JsonSerializable()
class QuestionAuthorBean {
  int id;
  dynamic login;
  String avatar_url;
  String url;
  String email;

  //RatingBean rating;

  QuestionAuthorBean({
    required this.id,
    required this.login,
    required this.avatar_url,
    required this.url,
    required this.email,
    //   this.rating
  });

  factory QuestionAuthorBean.fromJson(Map<String, dynamic> json) => _$QuestionAuthorBeanFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionAuthorBeanToJson(this);
}

@JsonSerializable()
class ReplyBean {
  String comment_ID;
  String content;
  QuestionAuthorBean? author;
  String datetime;

  //RatingBean rating;

  ReplyBean({
    required this.comment_ID,
    required this.content,
    required this.author,
    required this.datetime,
    //   this.rating
  });

  factory ReplyBean.fromJson(Map<String, dynamic> json) => _$ReplyBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ReplyBeanToJson(this);
}
