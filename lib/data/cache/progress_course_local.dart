import 'dart:convert';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/utils.dart';
import '../models/user_course.dart';

@provide
@singleton
class ProgressCoursesLocalStorage {
  List<UserCourseResponse> getUserCoursesLocal() {
    try {
      List<String>? cached = preferences?.getStringList('userCourses');
      cached ??= [];

      return cached.map((json) => UserCourseResponse.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      throw Exception();
    }
  }

  void saveProgressCourses(UserCourseResponse userCourseResponse) {
    String json = jsonEncode(userCourseResponse.toJson());

    List<String>? cached = preferences?.getStringList('userCourses');

    cached ??= [];

    cached = [];
    cached.add(json);

    preferences!.setStringList('userCourses', cached);
  }
}
