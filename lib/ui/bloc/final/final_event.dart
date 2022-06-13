import 'package:meta/meta.dart';

@immutable
abstract class FinalEvent {}

class FetchEvent extends FinalEvent {
    final int courseId;
    FetchEvent(this.courseId);
}