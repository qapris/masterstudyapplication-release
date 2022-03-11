import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';
import 'package:rxdart/rxdart.dart';

import './bloc.dart';

@provide
class SearchDetailBloc extends Bloc<SearchDetailEvent, SearchDetailState> {
  final CoursesRepository _coursesRepository;

  SearchDetailBloc(this._coursesRepository) : super(InitialSearchDetailState());

  @override
  SearchDetailState get initialState => InitialSearchDetailState();

  /*Stream<SearchDetailState> transformEvents(
    Stream<SearchDetailEvent> events,
    Stream<SearchDetailState> Function(SearchDetailEvent event) next,
  ) {
    return super.transformEvents(
      events.debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }*/

  @override
  // ignore: must_call_super
  void onTransition(Transition<SearchDetailEvent, SearchDetailState> transition) {}

  Stream<SearchDetailState> mapEventToState(
    SearchDetailEvent event,
  ) async* {
    if (event is FetchEvent) {
      if (event.query.isNotEmpty) {
        try {
          yield LoadingSearchDetailState();

          CourcesResponse response = await _coursesRepository.getCourses(searchQuery: event.query);

          yield LoadedSearchDetailState(response.courses);
        } catch (error, stacktrace) {
          print(error);
          print(stacktrace);
          yield NotingFoundSearchDetailState();
        }
      }
    }
  }
}
