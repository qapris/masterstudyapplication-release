import 'package:json_annotation/json_annotation.dart';

part 'AppSettings.g.dart';

@JsonSerializable()
class AppSettings {
  AddonsBean? addons;
  List<HomeLayoutBean?> home_layout;
  OptionsBean? options;
  bool demo;

  AppSettings({
    required this.addons,
    required this.home_layout,
    required this.options,
    required this.demo,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);
}


@JsonSerializable()
class HomeLayoutBean {
  num id;
  String? name;
  bool enabled;

  HomeLayoutBean({required this.id, this.name, required this.enabled});

  factory HomeLayoutBean.fromJson(Map<String, dynamic> json) => _$HomeLayoutBeanFromJson(json);

  Map<String, dynamic> toJson() => _$HomeLayoutBeanToJson(this);
}


@JsonSerializable()
class AddonsBean {
  String shareware;
  String sequential_drip_content;
  String gradebook;
  String live_streams;
  String enterprise_courses;
  String assignments;
  String point_system;
  String statistics;
  String online_testing;
  String course_bundle;
  String multi_instructors;

  AddonsBean({required this.shareware,
    required this.sequential_drip_content,
    required this.gradebook,
    required this.live_streams,
    required this.enterprise_courses,
    required this.assignments,
    required this.point_system,
    required this.statistics,
    required this.online_testing,
    required this.course_bundle,
    required this.multi_instructors});

  factory AddonsBean.fromJson(Map<String, dynamic> json) => _$AddonsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$AddonsBeanToJson(this);
}


@JsonSerializable()
class OptionsBean {
  String logo;
  ColorBean? main_color;
  ColorBean? secondary_color;
  bool app_view;
  num posts_count;

  OptionsBean({
    required this.logo,
    required this.main_color,
    required this.secondary_color,
    required this.app_view,
    required this.posts_count,
  });

  factory OptionsBean.fromJson(Map<String, dynamic> json) => _$OptionsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$OptionsBeanToJson(this);
}


@JsonSerializable()
class ColorBean {
  num r;
  num g;
  num b;
  num a;

  ColorBean({required this.r, required this.g, required this.b, required this.a});

  factory ColorBean.fromJson(Map<String, dynamic> json) => _$ColorBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ColorBeanToJson(this);
}


