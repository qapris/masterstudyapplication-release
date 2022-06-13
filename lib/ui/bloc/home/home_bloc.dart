
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';
import 'package:masterstudy_app/data/repository/home_repository.dart';
import 'package:masterstudy_app/data/repository/instructors_repository.dart';

import '../../../data/models/AppSettings.dart';
import './bloc.dart';

@provide
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  final CoursesRepository _coursesRepository;
  final InstructorsRepository _instructorsRepository;

  HomeState get initialState => InitialHomeState();

  HomeBloc(this._homeRepository, this._coursesRepository, this._instructorsRepository) : super(InitialHomeState()) {
    on<FetchEvent>((event, emit) async {
      if (state is ErrorHomeState) emit(InitialHomeState());
      try {
        var layouts = (await _homeRepository.getAppSettings()).home_layout;

        layouts.removeWhere((element) => element?.enabled == false);

        var categories = await _homeRepository.getCategories();
        var coursesFree = await _coursesRepository.getCourses(sort: Sort.free);
        var coursesNew = await _coursesRepository.getCourses(sort: Sort.date_low);
        var coursesTrending = await _coursesRepository.getCourses(sort: Sort.rating);
        var instructors = await _instructorsRepository.getInstructors(InstructorsSort.rating);

        AppSettings appSettings = await _homeRepository.getAppSettings();

        emit(LoadedHomeState(categories, coursesTrending.courses, layouts, coursesNew.courses, coursesFree.courses, instructors, appSettings));
      } catch (error, stacktrace) {
        print(error);
        print(stacktrace);
        emit(ErrorHomeState());
      }
    });
  }
}
