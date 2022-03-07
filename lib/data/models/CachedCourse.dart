import 'package:json_annotation/json_annotation.dart';
import 'package:masterstudy_app/data/models/user_course.dart';

import 'LessonResponse.dart';
import 'curriculum.dart';

part 'CachedCourse.g.dart';

@JsonSerializable(explicitToJson: true)
class CachedCourse {
  int id;
  String hash;
  PostsBean? postsBean;
  CurriculumResponse? curriculumResponse;
  List<LessonResponse?> lessons;

  CachedCourse({
    required this.id,
    this.postsBean,
    required this.curriculumResponse,
    required this.lessons,
    required this.hash,
  });

  factory CachedCourse.fromJson(Map<String, dynamic> json) => _$CachedCourseFromJson(json);

  Map<String, dynamic> toJson() => _$CachedCourseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CachedCourses {
  List<CachedCourse?> courses;

  CachedCourses({required this.courses});

  factory CachedCourses.fromJson(Map<String, dynamic> json) => _$CachedCoursesFromJson(json);

  Map<String, dynamic> toJson() => _$CachedCoursesToJson(this);
}
