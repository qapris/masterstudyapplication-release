// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CachedCourse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CachedCourse _$CachedCourseFromJson(Map<String, dynamic> json) {
  return CachedCourse(
    id: json['id'] as int,
    postsBean: json['postsBean'] == null ? null : PostsBean.fromJson(json['postsBean'] as Map<String, dynamic>),
    curriculumResponse: json['curriculumResponse'] == null ? null : CurriculumResponse.fromJson(json['curriculumResponse'] as Map<String, dynamic>),
    lessons: (json['lessons'] as List).map((e) => e == null ? null : LessonResponse.fromJson(e as Map<String, dynamic>)).toList(),
    hash: json['hash'] as String,
  );
}

Map<String, dynamic> _$CachedCourseToJson(CachedCourse instance) => <String, dynamic>{
      'id': instance.id,
      'hash': instance.hash,
      'postsBean': instance.postsBean?.toJson(),
      'curriculumResponse': instance.curriculumResponse?.toJson(),
      'lessons': instance.lessons.map((e) => e?.toJson()).toList(),
    };

CachedCourses _$CachedCoursesFromJson(Map<String, dynamic> json) {
  return CachedCourses(
    courses: (json['courses'] as List).map((e) => e == null ? null : CachedCourse.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

Map<String, dynamic> _$CachedCoursesToJson(CachedCourses instance) => <String, dynamic>{
      'courses': instance.courses.map((e) => e?.toJson()).toList(),
    };
