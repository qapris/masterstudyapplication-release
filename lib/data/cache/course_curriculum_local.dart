import 'dart:convert';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/utils.dart';
import '../models/curriculum.dart';

@provide
@singleton
class CurriculumLocalStorage {
  List<CurriculumResponse> getCurriculumLocal(int id) {
    try {
      List<String>? cached = preferences?.getStringList('courseCurriculum');
      cached ??= [];

      return cached.map((json) => CurriculumResponse.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      throw Exception();
    }
  }

  void saveCurriculum(CurriculumResponse curriculumResponse, int id) {
    String json = jsonEncode(curriculumResponse.toJson());

    List<String>? cached = preferences?.getStringList('courseCurriculum');

    cached ??= [];

    cached = [];
    cached.add(json);

    preferences?.setStringList('courseCurriculum', cached);
  }
}
