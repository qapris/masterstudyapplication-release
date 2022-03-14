import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';

import './bloc.dart';

@provide
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final CoursesRepository coursesRepository;

  FavoritesState get initialState => InitialFavoritesState();

  FavoritesBloc(this.coursesRepository) : super(InitialFavoritesState()) {
    on<FavoritesEvent>((event, emit) async {
      await _favourites(event, emit);
    });
  }

  @override
  Future<void> _favourites(FavoritesEvent event, Emitter<FavoritesState> emit) async {
    if (event is FetchFavorites) {
      if (state is ErrorFavoritesState) emit(InitialFavoritesState());
      try {
        var courses = await coursesRepository.getFavoriteCourses();
        if (courses.courses.isNotEmpty) {
          emit(LoadedFavoritesState(courses.courses));
        } else {
          emit(EmptyFavoritesState());
        }
      } catch (_) {
        emit(ErrorFavoritesState());
      }
    }
    if (event is DeleteEvent) {
      try {
        var courses = (state as LoadedFavoritesState).favoriteCourses;
        courses.removeWhere((item) => item?.id == event.courseId);
        await coursesRepository.deleteFavoriteCourse(event.courseId);
        emit(LoadedFavoritesState(courses));
      } catch (_) {}
    }
  }
}
