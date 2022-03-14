import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';

import './bloc.dart';

@provide
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthState get initialState => InitialAuthState();

  AuthBloc(this._repository) : super(InitialAuthState()) {
    on<AuthEvent>((event, emit) async {
      await _authMap(event, emit);
    });
  }

  Future<void> _authMap(AuthEvent event, Emitter<AuthState> emit) async {
    if (event is RegisterEvent) {
      emit(LoadingAuthState());
      try {
        await _repository.register(event.login, event.email, event.password);
        emit(SuccessAuthState());
      } catch (error, stacktrace) {
        var errorData = json.decode(error.toString());
        emit(_errorToState(errorData['message']));
      }
    }

    if (event is LoginEvent) {
      emit(LoadingAuthState());
      try {
        await _repository.authUser(event.login, event.password);
        emit(SuccessAuthState());
      } catch (error, stacktrace) {
        var errorData = json.decode(error.toString());

        emit(_errorToState(errorData['message']));
      }
    }

    if (event is DemoAuthEvent) {
      emit(LoadingAuthState());
      try {
        await _repository.demoAuth();
        emit(SuccessAuthState());
      } catch (error) {
        var errorData = json.decode(error.toString());
        emit(_errorToState(errorData['message']));
      }
    }

    if (event is CloseDialogEvent) {
      emit(InitialAuthState());
    }
  }

  _errorToState(message) async* {
    emit(ErrorAuthState(message));
    //yield InitialAuthState();
  }
}
