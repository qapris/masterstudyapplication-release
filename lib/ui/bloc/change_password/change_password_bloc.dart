import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';
import 'package:masterstudy_app/ui/bloc/change_password/bloc.dart';

@provide
class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthRepository _authRepository;

  ChangePasswordState get initialState => InitialChangePasswordState();

  ChangePasswordBloc(this._authRepository) : super(InitialChangePasswordState()) {
    on<SendChangePasswordEvent>((event, emit) async {
      try {
        emit(LoadingChangePasswordState());
        Response response = await _authRepository.changePassword(event.oldPassword, event.newPassword);

        if(response.data['modified']['new_password'] == false) {
          emit(ErrorChangePasswordState(response.data['values']['old_password'] ?? response.data['values']['new_password']));
        }else{
          emit(SuccessChangePasswordState());
        }

      } on DioError catch (e) {
        log(e.response.toString());
      }
    });
  }
}
