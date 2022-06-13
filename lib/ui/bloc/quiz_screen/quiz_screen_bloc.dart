import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';
import './bloc.dart';

@provide
class QuizScreenBloc extends Bloc<QuizScreenEvent, QuizScreenState> {
  final LessonRepository _repository;

  QuizScreenState get initialState => InitialQuizScreenState();

  QuizScreenBloc(this._repository) : super(InitialQuizScreenState()) {
    on<FetchEvent>((event, emit) async {
      try {
 emit(LoadedQuizScreenState(event.quizResponse));
        var response = await _repository.getLesson(event.courseId, event.lessonId);
        emit(LoadedQuizScreenState(response));
      } catch (e, s) {
        print(e);
        print(s);
      }
    });
  }
}
