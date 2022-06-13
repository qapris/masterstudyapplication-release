import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/AddToCartResponse.dart';
import 'package:masterstudy_app/data/models/AppSettings.dart';
import 'package:masterstudy_app/data/models/AssignmentResponse.dart';
import 'package:masterstudy_app/data/models/FinalResponse.dart';
import 'package:masterstudy_app/data/models/InstructorsResponse.dart';
import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:masterstudy_app/data/models/OrdersResponse.dart';
import 'package:masterstudy_app/data/models/PopularSearchesResponse.dart';
import 'package:masterstudy_app/data/models/QuestionAddResponse.dart';
import 'package:masterstudy_app/data/models/QuestionsResponse.dart';
import 'package:masterstudy_app/data/models/ReviewAddResponse.dart';
import 'package:masterstudy_app/data/models/ReviewResponse.dart';
import 'package:masterstudy_app/data/models/account.dart';
import 'package:masterstudy_app/data/models/auth.dart';
import 'package:masterstudy_app/data/models/category.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/data/models/course/CourseDetailResponse.dart';
import 'package:masterstudy_app/data/models/curriculum.dart';
import 'package:masterstudy_app/data/models/purchase/UserPlansResponse.dart';
import 'package:masterstudy_app/data/models/user_course.dart';

import '../models/purchase/AllPlansResponse.dart';
import '../utils.dart';

@provide
@singleton
class UserApiProvider {
  final _dio;

  UserApiProvider(this._dio);

  //SignIn
  Future<AuthResponse> authUser(String login, String password) async {
    Response response = await _dio.post(apiEndpoint + "login", data: {
      "login": login,
      "password": password,
    });
    return AuthResponse.fromJson(response.data);
  }

  //SignUp
  Future<AuthResponse> signUpUser(String login, String email, String password) async {
    Response response = await _dio.post(apiEndpoint + "registration", data: {
      "login": login,
      "email": email,
      "password": password,
    });
    return AuthResponse.fromJson(response.data);
  }

  //GetCategories
  Future<List<Category>> getCategories() async {
    Response response = await _dio.get(apiEndpoint + "categories");
    return (response.data as List).map((value) {
      return Category.fromJson(value);
    }).toList();
  }

  //GetAppSettings
  Future<AppSettings> getAppSettings() async {
    Response response = await _dio.get(apiEndpoint + "app_settings/");
    return AppSettings.fromJson(response.data);
  }

  //GetCourses
  Future<CourcesResponse> getCourses(Map<String, dynamic> params) async {
    Response response = await _dio.get(apiEndpoint + "courses/", queryParameters: params);
    return CourcesResponse.fromJson(response.data);
  }

  //GetFavouriteCourses
  Future<CourcesResponse> getFavoriteCourses() async {
    Response response = await dio.get(
      apiEndpoint + "courses/",
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );
    return CourcesResponse.fromJson(response.data);
  }

  //addCourse
  Future addFavoriteCourse(int courseId) async {
    Response response = await dio.put(
      apiEndpoint + "favorite",
      queryParameters: {"id": courseId},
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );
    return CourcesResponse.fromJson(response.data);
  }

  //deleteCourse
  Future deleteFavoriteCourse(int courseId) async {
    Response response = await dio.delete(
      apiEndpoint + "favorite",
      queryParameters: {"id": courseId},
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );
    return CourcesResponse.fromJson(response.data);
  }

  //getInstructors
  Future<InstructorsResponse> getInstructors(Map<String, dynamic> params) async {
    Response response = await _dio.get(apiEndpoint + "instructors", queryParameters: params);
    return InstructorsResponse.fromJson(response.data);
  }

  //getAccount
  Future<Account> getAccount({int? accountId}) async {
    var params;
    if (accountId != null) params = {"id": accountId};
    Response response = await dio.get(apiEndpoint + "account/",
        queryParameters: params,
        options: Options(
          headers: {"requirestoken": "true"},
        ));
    return Account.fromJson(response.data);
  }

  //uploadProfilePhoto
  Future<Response> uploadProfilePhoto(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    Response response = await dio.post(
      apiEndpoint + "account/edit_profile/",
      data: formData,
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );

    return response;
  }

  //editProfile
  Future editProfile(
    String firstName,
    String lastName,
    String password,
    String description,
    String position,
    String facebook,
    String instagram,
    String twitter,
  ) async {
    Map<String, String> map = {
      "first_name": firstName,
      "last_name": lastName,
      "position": position,
      "description": description,
      "facebook": facebook,
      "instagram": instagram,
      "twitter": twitter,
    };
    if (password.isNotEmpty) map.addAll({"password": password});
    dio.post(apiEndpoint + "account/edit_profile/",
        data: map,
        options: Options(
          headers: {"requirestoken": "true"},
        ));
    return null;
  }

  //getCourse
  Future<CourseDetailResponse> getCourse(int id) async {
    Response response = await dio.get(
      apiEndpoint + "course",
      queryParameters: {"id": id},
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );

    return CourseDetailResponse.fromJson(response.data);
  }

  //getReviews
  Future<ReviewResponse> getReviews(int id) async {
    Response response = await _dio.get(
      apiEndpoint + "course_reviews",
      queryParameters: {"id": id},
    );
    return ReviewResponse.fromJson(response.data);
  }

  //addReviews
  Future<ReviewAddResponse> addReviews(int id, int mark, String review) async {
    Response response = await dio.put(apiEndpoint + "course_reviews",
        queryParameters: {"id": id, "mark": mark, "review": review},
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    return ReviewAddResponse.fromJson(response.data);
  }

  //getUserCourses
  Future<UserCourseResponse> getUserCourses() async {
    Response response = await dio.post(
      apiEndpoint + "user_courses?page=0",
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );

    return UserCourseResponse.fromJson(response.data);
  }

  //getCourseCurriculum
  Future<CurriculumResponse> getCourseCurriculum(int id) async {
    Response response = await dio.post(apiEndpoint + "course_curriculum",
        data: {"id": id},
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    return CurriculumResponse.fromJson(response.data);
  }

  //getAssignmentInfo
  Future<AssignmentResponse> getAssignmentInfo(int course_id, int assignment_id) async {
    Map<String, int> map = {
      "course_id": course_id,
      "assignment_id": assignment_id,
    };

    Response response = await dio.post(apiEndpoint + "assignment",
        data: map,
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    return AssignmentResponse.fromJson(response.data);
  }

  //startAssignment
  Future<AssignmentResponse> startAssignment(int course_id, int assignment_id) async {
    Map<String, int> map = {
      "course_id": course_id,
      "assignment_id": assignment_id,
    };

    Response response = await dio.put(apiEndpoint + "assignment/start",
        data: map,
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    return AssignmentResponse.fromJson(response.data);
  }

  //addAssignment
  Future<AssignmentResponse> addAssignment(int course_id, int user_assignment_id, String content) async {
    Map<String, dynamic> map = {
      "course_id": course_id,
      "user_assignment_id": user_assignment_id,
      "content": content,
    };

    Response response = await dio.post(apiEndpoint + "assignment/add",
        data: map,
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    return AssignmentResponse.fromJson(response.data);
  }

  //uploadAssignmentFile
  Future<String> uploadAssignmentFile(int course_id, int user_assignment_id, File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "course_id": course_id,
      "user_assignment_id": user_assignment_id,
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });

    Response response = await dio.post(apiEndpoint + "assignment/add/file",
        data: formData,
        options: Options(
          headers: {"requirestoken": "true"},
        ));
    return response.toString();
  }

  //getLesson
  Future<LessonResponse> getLesson(dynamic courseId, dynamic lessonId) async {
    Response response = await dio.post(apiEndpoint + "course/lesson",
        data: {"course_id": courseId, "item_id": lessonId},
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    return LessonResponse.fromJson(response.data);
  }

  //completeLesson
  Future completeLesson(int courseId, int lessonId) async {
    Response response = await dio.put(apiEndpoint + "course/lesson/complete",
        data: {"course_id": courseId, "item_id": lessonId},
        options: Options(
          headers: {"requirestoken": "true"},
        ));
    return;
  }

  //getQuiz
  Future<LessonResponse> getQuiz(int courseId, int lessonId) async {
    Response response = await dio.post(apiEndpoint + "course/quiz",
        data: {"course_id": courseId, "item_id": lessonId},
        options: Options(
          headers: {"requirestoken": "true"},
        ));
    return LessonResponse.fromJson(response.data);
  }

  //getQuestions
  Future<QuestionsResponse> getQuestions(int lessonId, int page, String search, String authorIn) async {
    Map<String, dynamic> map = {
      "id": lessonId,
      "page": page,
    };

    if (search != "") map['search'] = search;
    if (authorIn != "") map['author__in'] = authorIn;

    Response response = await dio.post(apiEndpoint + "lesson/questions",
        data: map,
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    return QuestionsResponse.fromJson(response.data);
  }

  //addQuestion
  Future<QuestionAddResponse> addQuestion(int lessonId, String comment, int parent) async {
    late Response response;
    var data = {
      'id': lessonId,
      'comment': comment,
      'parent': parent,
    };

    response = await dio.put(
      apiEndpoint + "lesson/questions",
      data: data,
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );

    return QuestionAddResponse.fromJson(response.data);
  }

  //popularSearches
  Future<PopularSearchesResponse> popularSearches(int limit) async {
    Response response = await _dio.get(apiEndpoint + "popular_searches", queryParameters: {"limit": limit});
    return PopularSearchesResponse.fromJson(response.data);
  }

  //getUserPlans
  Future<UserPlansResponse?> getUserPlans(int courseId) async {
    Response response = await dio.post(apiEndpoint + "user_plans",
        data: {'course_id': courseId},
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    if(response.data.isEmpty) {
      return null;
    }else {
      return UserPlansResponse.fromJson(response.data);
    }
  }

  //getPlans
  Future<AllPlansResponse> getPlans(int courseId) async {
    log(courseId.toString());
    Response response = await dio.get(apiEndpoint + "plans",
        queryParameters: {'course_id': courseId},
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    log(response.data.toString());
    return AllPlansResponse.fromJsonArray(response.data);
  }

  //getOrders
  Future<OrdersResponse> getOrders() async {
    Response response = await dio.post(apiEndpoint + "user_orders",
        options: Options(
          headers: {"requirestoken": "true"},
        ));
    return OrdersResponse.fromJson(response.data);
  }

  //addToCart
  Future<AddToCartResponse> addToCart(int courseId) async {
    Response response = await dio.put(apiEndpoint + "add_to_cart",
        data: {"id": courseId},
        options: Options(
          headers: {"requirestoken": "true"},
        ));
    return AddToCartResponse.fromJson(response.data);
  }

  //usePlan
  Future<bool?> usePlan(int courseId, int subscriptionId) async {
    Response response = await dio.put(apiEndpoint + "use_plan",
        queryParameters: {"course_id": courseId, "subscription_id": subscriptionId},
        options: Options(
          headers: {"requirestoken": "true"},
        ));

    if (response.statusCode == 200) return true;
    return null;
  }

  //getLocalization
  Future<Map<String, dynamic>> getLocalization() async {
    var data = await _dio.get(apiEndpoint + "translations");
    if (data.statusCode == 200) return Future.value(data.data);
    return Future.error("");
  }

  //getCourseResults
  Future<FinalResponse> getCourseResults(int courseId) async {
    Response response = await dio.post(
      apiEndpoint + "course/results",
      data: {"course_id": courseId},
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );
    return FinalResponse.fromJson(response.data);
  }

  //demoAuth
  Future<String> demoAuth() async {
    Response response = await _dio.get(
      apiEndpoint + "demo",
    );
    return response.data['token'];
  }

  //restorePassword
  Future<Response> restorePassword(String email) async {
    Response response = await _dio.post(apiEndpoint + "account/restore_password", data: {"email": email});
    return response;
  }

  //restorePassword
  Future<Response> changePassword(String oldPassword, String newPassword) async {
    var queryParams = {
      'old_password': oldPassword,
      'new_password': newPassword,
    };

    Response response = await dio.post(apiEndpoint + "account/edit_profile", queryParameters: queryParams);

    return response;
  }

  //verifyInApp
  Future<bool> verifyInApp(String serverVerificationData, String price) async {
    Response response = await dio.post(
      apiEndpoint + "verify_purchase",
      data: {"receipt": serverVerificationData, "price": price},
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );
    if (response.statusCode == 200) return true;
    return false;
  }

  Future<TokenAuthToCourse> getTokenToCourse(int courseId) async {
    Response response = await dio.post(
      apiEndpoint + 'get_auth_token_to_course',
      data: {'course_id': courseId},
      options: Options(
        headers: {"requirestoken": "true"},
      ),
    );

    return TokenAuthToCourse.fromJson(response.data);
  }
}
