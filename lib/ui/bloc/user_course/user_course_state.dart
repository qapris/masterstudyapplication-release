import 'package:masterstudy_app/data/models/curriculum.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UserCourseState {}

class InitialUserCourseState extends UserCourseState {}
class ErrorUserCourseState extends UserCourseState {}

class LoadedUserCourseState extends UserCourseState {
  final bool? isCached;
  final List<SectionItem>? sections;
  final String? progress;
  final String? current_lesson_id;
  final String? lesson_type;
  final CurriculumResponse? response;
  final bool? showCachingProgress;
  LoadedUserCourseState(this.sections, this.progress, this.current_lesson_id, this.lesson_type, this.response, this.isCached, this.showCachingProgress);
}
