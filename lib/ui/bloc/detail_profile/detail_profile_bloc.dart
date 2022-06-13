
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/account.dart';
import 'package:masterstudy_app/data/repository/account_repository.dart';
import 'package:masterstudy_app/data/repository/courses_repository.dart';

import './bloc.dart';

@provide
class DetailProfileBloc extends Bloc<DetailProfileEvent, DetailProfileState> {
  final AccountRepository _repository;
  final CoursesRepository _coursesRepository;

  DetailProfileState get initialState => InitialDetailProfileState();

  Account? account;
  int? _teacherId;

  void setAccount(Account account) {
    this.account = account;
  }

  void setTeacherId(int teacherId) {
    _teacherId = teacherId;
  }

  DetailProfileBloc(this._repository, this._coursesRepository) : super(InitialDetailProfileState()) {
    on<LoadDetailProfile>((event, emit) async {
      if (account == null) {
        try {
          account = await _repository.getAccountById(_teacherId!);
          var courses = await _coursesRepository.getCourses(authorId: _teacherId!);
          emit(LoadedDetailProfileState(courses.courses, true));
        } catch (e, s) {
          print(e);
          print(s);
        }
      } else {
        emit(LoadedDetailProfileState(null, false));
      }
    });
  }





}
