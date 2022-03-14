import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/account.dart';
import 'package:masterstudy_app/data/repository/account_repository.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';

import './bloc.dart';

@provide
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AccountRepository _accountRepository;
  final AuthRepository _authRepository;
  late Account account;

  ProfileState get initialState => InitialProfileState();

  ProfileBloc(this._accountRepository, this._authRepository) : super(InitialProfileState()) {
    on<ProfileEvent>((event, emit) async => await _profile(event, emit));
  }

  Future<void> _profile(ProfileEvent event, Emitter<ProfileState> emit) async {
    if (event is FetchProfileEvent) {
      try {
        Account account = await _accountRepository.getUserAccount();
        emit(LoadedProfileState(account));
      } catch (excaption, stacktrace) {
        print(excaption);
        print(stacktrace);
      }
    }
    if (event is UpdateProfileEvent) {
      emit(InitialProfileState());
      try {
        Account account = await _accountRepository.getUserAccount();
        emit(LoadedProfileState(account));
      } catch (excaption, stacktrace) {
        print(excaption);
        print(stacktrace);
      }
    }
    if (event is LogoutProfileEvent) {
      await _authRepository.logout();
      emit(LogoutProfileState());
    }
  }
}
