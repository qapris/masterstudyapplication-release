import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/models/CachedCourse.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';
import 'package:masterstudy_app/data/repository/user_course_repository.dart';
import './bloc.dart';

@provide
class UserCourseBloc extends Bloc<UserCourseEvent, UserCourseState> {
  final UserCourseRepository _repository;
  final LessonRepository _lessonsRepository;
  final CacheManager cacheManager;

  UserCourseState get initialState => InitialUserCourseState();
  bool flag = false;

  UserCourseBloc(this._repository, this.cacheManager, this._lessonsRepository) : super(InitialUserCourseState()) {
    on<FetchEvent>((event, emit) async {
      if (state is ErrorUserCourseState) emit(InitialUserCourseState());

      int courseId = int.parse(event.userCourseScreenArgs.course_id!);

      var isCached = await cacheManager.isCached(courseId);

      try {
        var response = await _repository.getCourseCurriculum(courseId);

        _repository.saveLocalCurriculum(response, courseId);

        emit(LoadedUserCourseState(
          response.sections,
          response.progress_percent,
          response.current_lesson_id,
          response.lesson_type,
          response = response,
          isCached,
          false,
        ));

        if (isCached) {
          var currentHash = (await cacheManager.getFromCache())?.courses.firstWhere((element) => courseId == element?.id)?.hash;

          if (event.userCourseScreenArgs.postsBean?.hash != currentHash) {
            if (state is LoadedUserCourseState) {
              var state = this.state as LoadedUserCourseState;

              emit(LoadedUserCourseState(
                state.sections,
                state.progress,
                state.current_lesson_id,
                state.lesson_type,
                state.response,
                false,
                true,
              ));

              try {
                CachedCourse course = CachedCourse(
                    id: int.parse(event.userCourseScreenArgs.course_id!),
                    postsBean: event.userCourseScreenArgs.postsBean?..fromCache = true,
                    curriculumResponse: (state).response,
                    hash: event.userCourseScreenArgs.hash!,
                    lessons: []);

                var sections = (state).response?.sections.map((e) => e?.section_items);

                List<int?> iDs = [];

                sections?.forEach((element) {
                  element?.forEach((element) {
                    iDs.add(element?.item_id);
                  });
                });

                course.lessons = await _lessonsRepository.getAllLessons(int.parse(event.userCourseScreenArgs.course_id!), iDs);

                await cacheManager.writeToCache(course).then((value) => emit(LoadedUserCourseState(
                      state.sections,
                      state.progress,
                      state.current_lesson_id,
                      state.lesson_type,
                      state.response,
                      true,
                      false,
                    )));
              } catch (e, s) {
                print(e);
                print(s);
                emit(LoadedUserCourseState(
                  state.sections,
                  state.progress,
                  state.current_lesson_id,
                  state.lesson_type,
                  state.response,
                  false,
                  false,
                ));
              }
            }
          }
        }
      } catch (e) {
        if (isCached) {
          var cache = await cacheManager.getFromCache();

          if (cache?.courses.firstWhere((element) => courseId == element?.id) != null) {
            var response = cache?.courses.firstWhere((element) => courseId == element?.id)?.curriculumResponse;

            emit(LoadedUserCourseState(
              response!.sections,
              response.progress_percent,
              response.current_lesson_id,
              response.lesson_type,
              response = response,
              true,
              false,
            ));
          } else {
            emit(ErrorUserCourseState());
          }
        } else {
          emit(ErrorUserCourseState());
        }
      }
    });

    on<CacheCourseEvent>((event, emit) async {
      if (state is LoadedUserCourseState) {
        var state = this.state as LoadedUserCourseState;

        emit(LoadedUserCourseState(
          state.sections,
          state.progress,
          state.current_lesson_id,
          state.lesson_type,
          state.response,
          false,
          true,
        ));

        try {
          CachedCourse course = CachedCourse(
              id: int.parse(event.userCourseScreenArgs.course_id!),
              postsBean: event.userCourseScreenArgs.postsBean?..fromCache = true,
              curriculumResponse: (state).response,
              hash: event.userCourseScreenArgs.hash!,
              lessons: []);

          var sections = (state).response?.sections.map((e) => e?.section_items);

          List<int?> iDs = [];

          sections?.forEach((element) {
            element?.forEach((element) {
              iDs.add(element?.item_id);
            });
          });

          course.lessons = await _lessonsRepository.getAllLessons(int.parse(event.userCourseScreenArgs.course_id!), iDs);

          await cacheManager.writeToCache(course).then((value) => emit(LoadedUserCourseState(
                state.sections,
                state.progress,
                state.current_lesson_id,
                state.lesson_type,
                state.response,
                true,
                false,
              )));
        } catch (e, s) {
          print(e);
          print(s);
          emit(LoadedUserCourseState(
            state.sections,
            state.progress,
            state.current_lesson_id,
            state.lesson_type,
            state.response,
            false,
            false,
          ));
        }
      }
    });
  }
}
