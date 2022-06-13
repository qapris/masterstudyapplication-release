import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';
import 'package:masterstudy_app/data/repository/home_repository.dart';
import './bloc.dart';

@provide
class CategoryDetailBloc extends Bloc<CategoryDetailEvent, CategoryDetailState> {
  final HomeRepository _homeRepository;
  final CoursesRepository _coursesRepository;

  CategoryDetailState get initialState => InitialCategoryDetailState();

  CategoryDetailBloc(this._homeRepository, this._coursesRepository) : super(InitialCategoryDetailState()) {
    on<FetchEvent>((event, emit) async {
      emit(InitialCategoryDetailState());
      try {
        var categories = await _homeRepository.getCategories();

        var courses = await _coursesRepository.getCourses(categoryId: event.categoryId);

        emit(LoadedCategoryDetailState(categories, courses.courses));
      } catch (error, stackTrace) {
        print(error);
        print(stackTrace);
        emit(ErrorCategoryDetailState(event.categoryId));
      }
    });
  }
}
