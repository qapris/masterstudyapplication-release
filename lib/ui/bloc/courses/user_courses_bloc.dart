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
    on<FetchEvent>((event, emit) async {
      if (state is ErrorUserCoursesState) emit(InitialUserCoursesState());

      try {
        UserCourseResponse response = await _userCourseRepository.getUserCourses();

        _userCourseRepository.saveLocalUserCourses(response);

        if (response.posts.isEmpty) {
          emit(EmptyCoursesState());
        } else {
          emit(InitialUserCoursesState());
          emit(LoadedCoursesState(response.posts));
        }
      } catch (e) {
        var cache = await _cacheManager.getFromCache();

        if (cache != null) {
          List<UserCourseResponse> response = await _userCourseRepository.getUserCoursesLocal();

          for (var el in response) {
            for (var el1 in el.posts) {
              for (var el2 in cache.courses) {
                if (el1!.hash == el2!.hash) {
                  el2.postsBean!.progress = el1.progress;
                  el2.postsBean!.progress_label = el1.progress_label;
                }
              }
            }
          }

          try {
            List<PostsBean?> list = [];

            cache.courses.forEach((element) {
              list.add(element?.postsBean!);
            });

            emit(LoadedCoursesState(list));
          } catch (e) {
            emit(ErrorUserCoursesState());
          }
        } else {
          emit(EmptyCacheCoursesState());
        }
      }
    });
  }
}
