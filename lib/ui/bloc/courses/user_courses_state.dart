import 'package:equatable/equatable.dart';
import 'package:masterstudy_app/data/models/user_course.dart';

abstract class UserCoursesState extends Equatable {
  const UserCoursesState();
}

class InitialUserCoursesState extends UserCoursesState {
  @override
  List<Object> get props => [];
}
class ErrorUserCoursesState extends UserCoursesState {
  @override
  List<Object> get props => [];
}

class EmptyCoursesState extends UserCoursesState {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class LoadedCoursesState extends UserCoursesState {
  List<PostsBean> courses;

  LoadedCoursesState(this.courses);

  @override
  // TODO: implement props
  List<Object>? get props => null;
}
