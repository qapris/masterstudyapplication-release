import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';
import './bloc.dart';

@provide
class QuizLessonBloc extends Bloc<QuizLessonEvent, QuizLessonState> {
  final LessonRepository repository;
  final CacheManager cacheManager;

  QuizLessonState get initialState => InitialQuizLessonState();

  QuizLessonBloc(this.repository, this.cacheManager) : super(InitialQuizLessonState()) {
    on<FetchEvent>((event, emit) async {
      try {
        var response = await repository.getQuiz(event.courseId, event.lessonId);

        emit(LoadedQuizLessonState(response));
      } catch (e, s) {
        if (await cacheManager.isCached(event.courseId)) {
          emit(CacheWarningQuizLessonState());
        }
        print(e);
        print(s);
      }
    });
  }
}
