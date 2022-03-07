import 'package:json_annotation/json_annotation.dart';

part 'AssignmentResponse.g.dart';

@JsonSerializable()
class AssignmentResponse {
  String status;
  String title;
  String content;
  String comment;
  String button;
  SectionBean? section;
  String prev_lesson_type;
  String next_lesson_type;
  String prev_lesson;
  String next_lesson;
  String label;
  TranslationBean? translations;
  List<FilesBean?> files;
  dynamic draft_id = null;

  AssignmentResponse({
    required this.status,
    required this.translations,
    required this.title,
    required this.content,
    required this.draft_id,
    required this.button,
    required this.section,
    required this.prev_lesson_type,
    required this.next_lesson_type,
    required this.prev_lesson,
    required this.next_lesson,
    required this.label,
    required this.comment,
    required this.files,
  });

  factory AssignmentResponse.fromJson(Map<String, dynamic> json) => _$AssignmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentResponseToJson(this);
}

@JsonSerializable()
class SectionBean {
  String label;
  String number;
  var index = null;

  SectionBean({required this.label, required this.number, this.index});

  factory SectionBean.fromJson(Map<String, dynamic> json) => _$SectionBeanFromJson(json);

  Map<String, dynamic> toJson() => _$SectionBeanToJson(this);
}

@JsonSerializable()
class TranslationBean {
  String title;
  String content;
  String files;

  TranslationBean({required this.title, required this.content, required this.files});

  factory TranslationBean.fromJson(Map<String, dynamic> json) => _$TranslationBeanFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationBeanToJson(this);
}

@JsonSerializable()
class FilesBean {
  FileBean? data;

  FilesBean({required this.data});

  factory FilesBean.fromJson(Map<String, dynamic> json) => _$FilesBeanFromJson(json);

  Map<String, dynamic> toJson() => _$FilesBeanToJson(this);
}

@JsonSerializable()
class FileBean {
  String name;
  num id;
  String status;
  bool error;
  String link;

  FileBean({
    required this.name,
    required this.id,
    required this.status,
    required this.error,
    required this.link,
  });

  factory FileBean.fromJson(Map<String, dynamic> json) => _$FileBeanFromJson(json);

  Map<String, dynamic> toJson() => _$FileBeanToJson(this);
}
