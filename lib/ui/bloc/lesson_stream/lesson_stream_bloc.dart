
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';

import './bloc.dart';

@provide
class LessonStreamBloc extends Bloc<LessonStreamEvent, LessonStreamState> {
  final LessonRepository repository;
  final CacheManager cacheManager;

  LessonStreamState get initialState => InitialLessonStreamState();

  LessonStreamBloc(this.repository, this.cacheManager) : super(InitialLessonStreamState()) {
    on<FetchEvent>((event, emit) async {
      try {
        var response = await repository.getLesson(event.courseId, event.lessonId);
        print(response);
        emit(LoadedLessonStreamState(response));
      } catch (e, s) {
        if (await cacheManager.isCached(event.courseId)) {
          emit(CacheWarningLessonStreamState());
        }
        print(e);
        print(s);
      }
    });
  }
}
