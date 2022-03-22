import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/models/user_course.dart';
import 'package:masterstudy_app/data/repository/user_course_repository.dart';

import './bloc.dart';

@provide
class UserCoursesBloc extends Bloc<UserCoursesEvent, UserCoursesState> {
  final UserCourseRepository _userCourseRepository;
  final CacheManager _cacheManager;

  UserCoursesState get initialState => InitialUserCoursesState();

  UserCoursesBloc(this._userCourseRepository, this._cacheManager) : super(InitialUserCoursesState()) {
    on<UserCoursesEvent>((event, emit) async {
      await _userCourses(event, emit);
    });
  }

  Future<void> _userCourses(UserCoursesEvent event, Emitter<UserCoursesState> emit) async {
    if (event is FetchEvent) {
      if (state is ErrorUserCoursesState) emit(InitialUserCoursesState());
      try {
        UserCourseResponse response = await _userCourseRepository.getUserCourses();
        if (response.posts.isEmpty) {
          emit(EmptyCoursesState());
        } else {
          emit(InitialUserCoursesState());
          emit(LoadedCoursesState(response.posts));
        }
      } catch (e, s) {
        log(e.toString());
        print(e);
        print(s);
        var cache = await _cacheManager.getFromCache();
        if (cache != null) {
          try {
            List<PostsBean> list = [];
            cache.courses.forEach((element) {
              // list.add(element.postsBean.fromCache = true);
            });
            emit(LoadedCoursesState(list));
          } catch (e, s) {
            print(e);
            print(s);
            emit(ErrorUserCoursesState());
          }
        } else {
          emit(ErrorUserCoursesState());
        }
      }
    }
  }
}
