import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';
import './bloc.dart';

@provide
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthState get initialState => InitialAuthState();

  AuthBloc(this._repository) : super(InitialAuthState()) {
    on<RegisterEvent>((event, emit) async {
      emit(LoadingAuthState());
      try {
        await _repository.register(event.login, event.email, event.password);
        emit(SuccessAuthState());
      } on DioError catch (e) {
        log(e.response.toString());
        emit(ErrorAuthState(e.response?.data['message']));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(LoadingAuthState());
      try {
        await _repository.authUser(event.login, event.password);
        emit(SuccessAuthState());
      } on DioError catch (e) {
        emit(ErrorAuthState(e.response?.data['message']));
      }
    });

    on<DemoAuthEvent>((event, emit) async {
      emit(LoadingAuthState());
      try {
        await _repository.demoAuth();
        emit(SuccessAuthState());
      } catch (error) {
        log(error.toString());
        var errorData = json.decode(error.toString());
        emit(ErrorAuthState(errorData['message']));
      }
    });

    on<CloseDialogEvent>((event, emit) {
      emit(InitialAuthState());
    });
  }
}
