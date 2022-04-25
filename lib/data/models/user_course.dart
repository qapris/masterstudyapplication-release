
import 'package:json_annotation/json_annotation.dart';
import 'package:masterstudy_app/data/models/category.dart';

part 'user_course.g.dart';

@JsonSerializable()
class UserCourseResponse {
  List<PostsBean?> posts;
  String total;
  num offset;
  num total_posts;
  num pages;

  UserCourseResponse({
    required this.posts,
    required this.total,
    required this.offset,
    required this.total_posts,
    required this.pages,
  });

  factory UserCourseResponse.fromJson(Map<String, dynamic> json) => _$UserCourseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserCourseResponseToJson(this);
}

@JsonSerializable()
class PostsBean {
  dynamic image_id;
  dynamic title;
  dynamic link;
  dynamic image;
  List<dynamic> terms;
  List<dynamic> terms_list;
  dynamic views;
  dynamic price;
  dynamic sale_price;
  PostStatusBean? post_status;
  dynamic progress;
  dynamic progress_label;
  dynamic current_lesson_id;
  dynamic course_id;
  dynamic lesson_id;
  dynamic start_time;
  dynamic duration;
  dynamic app_image;
  PostAuthorBean? author;
  String? lesson_type;
  String? hash;
  List<Category?> categories_object;
  bool? fromCache;

  PostsBean(
      {required this.image_id,
      required this.title,
      required this.link,
      required this.image,
      required this.terms,
      required this.terms_list,
      required this.views,
      required this.price,
      required this.sale_price,
      required this.post_status,
      required this.progress,
      required this.progress_label,
      required this.current_lesson_id,
      required this.course_id,
      required this.lesson_id,
      required this.start_time,
      required this.duration,
      required this.app_image,
      required this.author,
      required this.lesson_type,
      required this.categories_object,
      required this.hash,
      required this.fromCache});

  factory PostsBean.fromJson(Map<String, dynamic> json) => _$PostsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$PostsBeanToJson(this);
}

@JsonSerializable()
class PostStatusBean {
  String status;
  String label;

  PostStatusBean({required this.status, required this.label});

  factory PostStatusBean.fromJson(Map<String, dynamic> json) => _$PostStatusBeanFromJson(json);

  Map<String, dynamic> toJson() => _$PostStatusBeanToJson(this);
}

@JsonSerializable()
class PostAuthorBean {
  String? id;
  String? login;
  String? avatar_url;
  String? url;
  AuthorMetaBean? meta;

  //RatingBean rating;

  PostAuthorBean({
    required this.id,
    required this.login,
    required this.avatar_url,
    required this.url,
    required this.meta,
    //   this.rating
  });

  factory PostAuthorBean.fromJson(Map<String, dynamic> json) => _$PostAuthorBeanFromJson(json);

  Map<String, dynamic> toJson() => _$PostAuthorBeanToJson(this);
}

@JsonSerializable()
class AuthorMetaBean {
  String type;
  String label;

  String text;

  AuthorMetaBean({required this.type, required this.label, required this.text});

  factory AuthorMetaBean.fromJson(Map<String, dynamic> json) => _$AuthorMetaBeanFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorMetaBeanToJson(this);
}
