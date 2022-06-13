
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';

import './bloc.dart';

@provide
class TextLessonBloc extends Bloc<TextLessonEvent, TextLessonState> {
  final LessonRepository repository;
  final CacheManager cacheManager;

  TextLessonState get initialState => InitialTextLessonState();

  TextLessonBloc(this.repository, this.cacheManager) : super(InitialTextLessonState()) {
    on<FetchEvent>((event, emit) async {
      try {
        var response = await repository.getLesson(event.courseId, event.lessonId);
        emit(LoadedTextLessonState(response));
       /* if (response.fromCache && response.type == "slides") {
          emit(CacheWarningLessonState());
        }*/
      } catch (e, s) {
        print(e);
        print(s);
      }
    });

    on<CompleteLessonEvent>((event, emit) async {
      try {
        var response = await repository.completeLesson(event.courseId, event.lessonId);
      } catch (e, s) {
        print(e);
        print(s);
      }
    });
  }

}
