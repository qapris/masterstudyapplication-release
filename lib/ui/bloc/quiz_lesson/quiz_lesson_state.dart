import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QuizLessonState {}

class InitialQuizLessonState extends QuizLessonState {}

class CacheWarningQuizLessonState extends QuizLessonState {}

class LoadedQuizLessonState extends QuizLessonState {
  final LessonResponse quizResponse;

  LoadedQuizLessonState(this.quizResponse);
}
