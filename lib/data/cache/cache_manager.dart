import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/CachedCourse.dart';
import 'package:path_provider/path_provider.dart';

@provide
@singleton
class CacheManager {
  String cache = "";

  Future writeToCache(CachedCourse course) async {
    cache = await _readCache();
    debugPrint("writing to cache ...");

    if (cache.isEmpty) {
      debugPrint("cache is empty");
      debugPrint("writing course");
      debugPrint("cache before :$cache");
      var courseToCache = new CachedCourses(courses: [course].toList());
      cache = jsonEncode(courseToCache.toJson());
      debugPrint("cache after :$cache");
      debugPrint("course writed");
    } else {
      debugPrint("writing course");
      CachedCourses currentCache = CachedCourses.fromJson(json.decode(cache));
      currentCache.courses.removeWhere((element) => (element?.id == course.id));
      currentCache.courses.add(course);
      cache = jsonEncode(currentCache.toJson());
    }

    _writeCache(cache);
  }

  Future<CachedCourses?> getFromCache() async {
    cache = await _readCache();
    debugPrint("reading from cache ...");
    debugPrint("current cache:$cache");
    if (cache != "") {
      try {
        CachedCourses courses = await CachedCourses.fromJson(json.decode(cache));
        return courses;
      } catch (e, s) {
        print(e);
        print(s);
        return null;
      }
    } else {
      debugPrint("cache is empty returning null");
      return null;
    }
  }

  Future<bool> isCached(int id) async {
    if (cache == "") cache = await _readCache();
    if (cache == "") return false;

    CachedCourses courses = await CachedCourses.fromJson(json.decode(cache));
    if (courses.courses.indexWhere((element) => element?.id == id) == -1) return false;
    var course = courses.courses.firstWhere((element) => element?.id == id);
    if (course != null) return true;
    return false;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/cache.txt');
  }

  Future<File> _writeCache(String cache) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString('$cache');
  }

  Future cleanCache() async {
    await _writeCache("");
  }

  Future<String> _readCache() async {
    try {
      final file = await _localFile;
      // Read the file.
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return empty string.
      return "";
    }
  }
}
