import 'package:meta/meta.dart';

@immutable
abstract class LessonZoomEvent {}

class FetchEvent extends LessonZoomEvent {
  final int courseId;
  final int lessonId;

  FetchEvent(this.courseId, this.lessonId);
}

class CompleteLessonEvent extends LessonZoomEvent {
  final int courseId;
  final int lessonId;

  CompleteLessonEvent(this.courseId, this.lessonId);
}
