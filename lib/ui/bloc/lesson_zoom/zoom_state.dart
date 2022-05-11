import 'package:meta/meta.dart';

import '../../../data/models/LessonResponse.dart';

@immutable
abstract class LessonZoomState {}

class InitialLessonZoomState extends LessonZoomState {}

class LoadedLessonZoomState extends LessonZoomState {
  final LessonResponse lessonResponse;

  LoadedLessonZoomState(this.lessonResponse);
}
