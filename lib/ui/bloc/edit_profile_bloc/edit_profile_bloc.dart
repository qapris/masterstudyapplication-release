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
    on<SaveEvent>((event, emit) async {
      try {
        emit(LoadingEditProfileState());
        if (event.photo != null) {
          await _repository.editProfile(
            event.firstName,
            event.lastName,
            event.password,
            event.description,
            event.position,
            event.facebook,
            event.twitter,
            event.instagram,
            event.photo!,
          );
        } else {
          await _repository.editProfile(
            event.firstName,
            event.lastName,
            event.password,
            event.description,
            event.position,
            event.facebook,
            event.twitter,
            event.instagram,
          );
        }

        await Future.delayed(Duration(milliseconds: 1000));
        emit(UpdateEditProfileState());
      } catch (e, s) {
        print(e);
        print(s);
        emit(ErrorEditProfileState());
        emit(InitialEditProfileState());
      }
    });

    on<CloseScreenEvent>((event, emit) {
      emit(CloseEditProfileState());
    });
  }
}
