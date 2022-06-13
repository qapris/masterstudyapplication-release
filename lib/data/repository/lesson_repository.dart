import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:masterstudy_app/data/network/api_provider.dart';

abstract class LessonRepository {
  Future<LessonResponse> getLesson(int courseId, int lessonId);

  Future<LessonResponse> getQuiz(int courseId, int lessonId);

  Future completeLesson(int courseId, int lessonId);

  Future<List<LessonResponse>> getAllLessons(int courseId, List<int?> lessonIds);
}

@provide
class LessonRepositoryImpl extends LessonRepository {
  final UserApiProvider _userApiProvider;
  final CacheManager cacheManager;

  LessonRepositoryImpl(this._userApiProvider, this.cacheManager);

  @override
  Future<LessonResponse> getLesson(int courseId, int lessonId) async {
    LessonResponse? response;
    var isCached = await cacheManager.isCached(courseId);
    try {
      response = await _userApiProvider.getLesson(courseId, lessonId)
        ..id = courseId;
    } catch (e, s) {
      print(e);
      print(s);
      if (isCached) {
        var course = (await cacheManager.getFromCache())?.courses.firstWhere((element) => element?.id == courseId);
        if (course?.lessons != null && course?.lessons.indexWhere((element) => element?.id == lessonId) != -1) {
          response = course?.lessons.firstWhere((element) => element?.id == lessonId);
        } else {
          return Future.error(e);
        }
      } else {
        return Future.error(e);
      }
    }
    return response!;
  }

  @override
  Future completeLesson(int courseId, int lessonId) async {
    await _userApiProvider.completeLesson(courseId, lessonId);
    return;
  }

  @override
  Future<LessonResponse> getQuiz(int courseId, int lessonId) async {
    return _userApiProvider.getQuiz(courseId, lessonId);
  }

  @override
  Future<List<LessonResponse>> getAllLessons(int courseId, List<dynamic> lessonIds) async {
    List<LessonResponse> lessons = [];
    await Future.forEach(lessonIds, (element) async {
      var response = await _userApiProvider.getLesson(courseId, element)
        ..id = element
        ..fromCache = true;
      lessons.add(response);
    });

    //downloading images
    await Future.forEach(lessons, (element) async {
      var index = lessons.indexOf(element as LessonResponse);

      //Removing srcset tags
      var setsToRemove = _getSrcSets(lessons[index].content);
      if (setsToRemove != null)
        for (String set in setsToRemove) {
          var currentElement = element;
          currentElement.content = currentElement.content.replaceFirst(set, "");
          lessons[lessons.indexOf(element)] = currentElement;
        }

      List<String> urls = _getLinkedFileUrls((element).content);

      for (String webUrl in urls) {
        var file64 = await _getBase64String(webUrl);
        var currentElement = element;
        currentElement.content = currentElement.content.replaceFirst(webUrl, file64);
        lessons[index] = currentElement;
      }
    });
    print(lessons);
    return lessons;
  }

  Future<String> _getBase64String(String url) async {
    var response = await get(Uri.parse(url));
    var prefix = "data:${response.headers['content-type']};base64, ";
    return prefix + base64Encode(response.bodyBytes);
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  _getSrcSets(String text) {
    RegExp exp = new RegExp(r'srcset="(.*?)"');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    return matches.map((match) {
      return text.substring(match.start, match.end);
    });
  }

  _getLinkedFileUrls(String text) {
    RegExp exp = new RegExp(r"""(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png|css)(:?(\?|\&)([^=]+)\=([^(?:"|')]+)|)""");
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    List<String> results = [];
    for (RegExpMatch match in matches) {
      var matchText = text.substring(match.start, match.end);
      results.add(matchText);
    }
    return results;
  }
}
