import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QuizScreenState {}

class InitialQuizScreenState extends QuizScreenState {}

class LoadedQuizScreenState extends QuizScreenState {
  final LessonResponse quizResponse;

  LoadedQuizScreenState(this.quizResponse);
}
