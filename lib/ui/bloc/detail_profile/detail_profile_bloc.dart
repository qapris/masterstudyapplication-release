import 'dart:async';
import 'dart:developer';

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

  DetailProfileBloc(this._repository, this._coursesRepository) : super(InitialDetailProfileState()) {
    on<DetailProfileEvent>((event, emit) async => await _detailProfile(event, emit));
  }

  Account? account;
  int? _teacherId;

  void setAccount(Account account) {
    this.account = account;
  }

  Future<void> _detailProfile(DetailProfileEvent event, Emitter<DetailProfileState> emit) async {
    if (event is LoadDetailProfile) {
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
    }
  }

  void setTeacherId(int teacherId) {
    _teacherId = teacherId;
  }
}
