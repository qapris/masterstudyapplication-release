// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LessonResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonResponse _$LessonResponseFromJson(Map<String, dynamic> json) {
  return LessonResponse(
    section: json['section'] == null ? null : SectionBean.fromJson(json['section'] as Map<String, dynamic>),
    title: json['title'] as String,
    type: json['type'] as String,
    content: json['content'] as String,
    materials: json['materials'] != null ?  (json['materials'] as List).map((e) => e == null ? null : Materials.fromJson(e as Map<String, dynamic>)).toList() : [],
    video: json['video']  ,
    video_poster: json['video_poster']  ,
    prev_lesson_type: json['prev_lesson_type']  ,
    next_lesson_type: json['next_lesson_type']  ,
    prev_lesson: json['prev_lesson'],
    next_lesson: json['next_lesson'],
    completed: json['completed'] as bool,
    next_lesson_available: json['next_lesson_available'] as bool,
    view_link: json['view_link'] as String,
    // quiz_data: (json['quiz_data'] as List).map((e) => e == null ? null : Quiz_dataBean.fromJson(e as Map<String, dynamic>)).toList(),
    time: json['time'] as num,
    time_left: json['time_left'] as num,
    quiz_time: json['quiz_time'],
    fromCache: json['fromCache'] as bool,
  )..id = json['id'] as int;
}

Map<String, dynamic> _$LessonResponseToJson(LessonResponse instance) => <String, dynamic>{
      'id': instance.id,
      'section': instance.section,
      'title': instance.title,
      'type': instance.type,
      'content': instance.content,
      'materials': instance.materials,
      'video': instance.video,
      'video_poster': instance.video_poster,
      'prev_lesson_type': instance.prev_lesson_type,
      'next_lesson_type': instance.next_lesson_type,
      'prev_lesson': instance.prev_lesson,
      'next_lesson': instance.next_lesson,
      'completed': instance.completed,
      'next_lesson_available': instance.next_lesson_available,
      'view_link': instance.view_link,
      // 'quiz_data': instance.quiz_data,
      'time': instance.time,
      'time_left': instance.time_left,
      'fromCache': instance.fromCache,
      'quiz_time': instance.quiz_time,
    };

SectionBean _$SectionBeanFromJson(Map<String, dynamic> json) {
  return SectionBean(
    label: json['label'] as String,
    number: json['number'] as String,
    index: json['index'] as num,
  );
}

Map<String, dynamic> _$SectionBeanToJson(SectionBean instance) => <String, dynamic>{
      'label': instance.label,
      'number': instance.number,
      'index': instance.index,
    };


Materials _$MaterialsFromJson(Map<String, dynamic> json) {
  return Materials(
    label: json['label'] as String,
    url: json['url'],
    size: json['size'],
    type: json['type'],
  );
}

Map<String, dynamic> _$MaterialsToJson(Materials instance) => <String, dynamic>{
  'label': instance.label,
  'url': instance.url,
  'size': instance.size,
  'type': instance.type,
};
