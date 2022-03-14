import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/account.dart';
import 'package:masterstudy_app/data/repository/account_repository.dart';

import './bloc.dart';

@provide
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final AccountRepository _repository;
  late Account account;

  EditProfileState get initialState => InitialEditProfileState();

  EditProfileBloc(this._repository) : super(InitialEditProfileState()) {
    on<EditProfileEvent>((event, emit) async {
      await _editProfile(event, emit);
    });
  }

  Future<void> _editProfile(EditProfileEvent event, Emitter<EditProfileState> emit) async {
    if (event is SaveEvent) {
      try {
        emit(LoadingEditProfileState());
        await _repository.editProfile(event.firstName, event.lastName, event.password, event.description, event.position, event.facebook, event.twitter, event.instagram, photo: event.photo);
        await Future.delayed(Duration(milliseconds: 1000));
        emit(CloseEditProfileState());
      } catch (e, s) {
        print(e);
        print(s);
        emit(ErrorEditProfileState());
        emit(InitialEditProfileState());
      }
    }
    if (event is CloseScreenEvent) {
      emit(CloseEditProfileState());
    }
  }
}
