
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/user_course_repository.dart';

import './bloc.dart';

@provide
class UserCourseLockedBloc extends Bloc<UserCourseLockedEvent, UserCourseLockedState> {
  final UserCourseRepository _repository;

  UserCourseLockedState get initialState => InitialUserCourseLockedState();

  UserCourseLockedBloc(this._repository) : super(InitialUserCourseLockedState()) {
    on<FetchEvent>((event, emit) async {
      try {
        var response = await _repository.getCourse(event.courseId);
        emit(LoadedUserCourseLockedState(response));
      } catch (e, s) {
        print(e);
        print(s);
      }
    });
  }
}
