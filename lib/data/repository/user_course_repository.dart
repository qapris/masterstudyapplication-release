
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/cache/progress_course_local.dart';
import 'package:masterstudy_app/data/models/course/CourseDetailResponse.dart';
import 'package:masterstudy_app/data/models/curriculum.dart';
import 'package:masterstudy_app/data/models/user_course.dart';
import 'package:masterstudy_app/data/network/api_provider.dart';

import '../cache/course_curriculum_local.dart';

abstract class UserCourseRepository {
  Future<UserCourseResponse> getUserCourses();

  Future<CurriculumResponse> getCourseCurriculum(int id);

  Future<CourseDetailResponse> getCourse(int courseId);

  void saveLocalUserCourses(UserCourseResponse userCourseResponse);

  Future<List<UserCourseResponse>> getUserCoursesLocal();

  void saveLocalCurriculum(CurriculumResponse curriculumResponse,int id);

  Future<List<CurriculumResponse>> getCurriculumLocal(int id);
}

class UserCourseRepositoryImpl extends UserCourseRepository {
  final UserApiProvider _apiProvider;
  final CacheManager cacheManager;
  final ProgressCoursesLocalStorage progressCoursesLocalStorage;
  final CurriculumLocalStorage curriculumLocalStorage;

  UserCourseRepositoryImpl(this._apiProvider, this.cacheManager, this.progressCoursesLocalStorage, this.curriculumLocalStorage);

  @override
  Future<UserCourseResponse> getUserCourses() {
    return _apiProvider.getUserCourses();
  }

  @override
  Future<CurriculumResponse> getCourseCurriculum(int id) {
    return _apiProvider.getCourseCurriculum(id);
  }

  @override
  Future<CourseDetailResponse> getCourse(int courseId) {
    return _apiProvider.getCourse(courseId);
  }

  void saveLocalUserCourses(UserCourseResponse userCourseResponse) {
    return progressCoursesLocalStorage.saveProgressCourses(userCourseResponse);
  }

  Future<List<UserCourseResponse>> getUserCoursesLocal() async {
    return await progressCoursesLocalStorage.getUserCoursesLocal();
  }

  void saveLocalCurriculum(CurriculumResponse curriculumResponse,int id) {
    return curriculumLocalStorage.saveCurriculum(curriculumResponse, id);
  }

  Future<List<CurriculumResponse>> getCurriculumLocal(int id) async {
    return await curriculumLocalStorage.getCurriculumLocal(id);
  }
}
