import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QuizScreenEvent {}

class FetchEvent extends QuizScreenEvent {
  final int courseId;
  final int lessonId;
  final LessonResponse quizResponse;

  FetchEvent(this.courseId, this.lessonId, this.quizResponse);
}
