import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';
import './bloc.dart';

@provide
class SearchDetailBloc extends Bloc<SearchDetailEvent, SearchDetailState> {
  final CoursesRepository _coursesRepository;

  SearchDetailState get initialState => InitialSearchDetailState();

  SearchDetailBloc(this._coursesRepository) : super(InitialSearchDetailState()) {
    on<FetchEvent>((event, emit) async {
      if (event.query.isNotEmpty) {
        try {
          emit(LoadingSearchDetailState());

          CourcesResponse response = await _coursesRepository.getCourses(searchQuery: event.query, categoryId: event.categoryId);

          emit(LoadedSearchDetailState(response.courses));
        } catch (error, stacktrace) {
          print(error);
          print(stacktrace);
          emit(NotingFoundSearchDetailState());
        }
      }
    });
  }
}
