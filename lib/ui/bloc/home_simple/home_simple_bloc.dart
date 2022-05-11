import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';

import './bloc.dart';

@provide
class HomeSimpleBloc extends Bloc<HomeSimpleEvent, HomeSimpleState> {
  final CoursesRepository _coursesRepository;

  HomeSimpleState get initialState => InitialHomeSimpleState();

  HomeSimpleBloc(this._coursesRepository) : super(InitialHomeSimpleState()) {
    on<FetchHomeSimpleEvent>((event, emit) async {
      try {
        var coursesNew = await _coursesRepository.getCourses(sort: Sort.date_low);

        emit(LoadedHomeSimpleState(coursesNew.courses));
      } catch (error, stackTrace) {
        print(error);
        print(stackTrace);
      }
    });
  }
}
