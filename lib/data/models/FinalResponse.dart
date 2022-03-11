import 'package:json_annotation/json_annotation.dart';

part 'FinalResponse.g.dart';

@JsonSerializable()
class FinalResponse {
  CourseBean? course;
  CurriculumBean? curriculum;
  bool course_completed = false;
  String? title;
  String? url;
  String? certificate_url;

  FinalResponse({required this.title,required this.course_completed} );

  factory FinalResponse.fromJson(Map<String, dynamic> json) => _$FinalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FinalResponseToJson(this);
}

@JsonSerializable()
class CourseBean {
  num? user_course_id;
  num? user_id;
  int? course_id;
  num? current_lesson_id;
  int? progress_percent;
  String? status;
  num? subscription_id;
  String? start_time;
  String? lng_code;
  num? enterprise_id;
  num? bundle_id;

  CourseBean({required this.user_course_id});

  factory CourseBean.fromJson(Map<String, dynamic> json) => _$CourseBeanFromJson(json);

  Map<String, dynamic> toJson() => _$CourseBeanToJson(this);
}

@JsonSerializable()
class CurriculumBean {
  TypeBean? multimedia;
  TypeBean? lesson;
  TypeBean? quiz;
  TypeBean? assignment;

  CurriculumBean({required this.multimedia, required this.lesson, required this.assignment, required this.quiz});

  factory CurriculumBean.fromJson(Map<String, dynamic> json) => _$CurriculumBeanFromJson(json);

  Map<String, dynamic> toJson() => _$CurriculumBeanToJson(this);
}

@JsonSerializable()
class TypeBean {
  num total;
  num completed;

  TypeBean({required this.total, required this.completed});

  factory TypeBean.fromJson(Map<String, dynamic> json) => _$TypeBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TypeBeanToJson(this);
}
