import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';
import 'package:masterstudy_app/ui/bloc/restore_password/bloc.dart';

@provide
class RestorePasswordBloc extends Bloc<RestorePasswordEvent, RestorePasswordState> {
  final AuthRepository _authRepository;

  RestorePasswordState get initialState => InitialRestorePasswordState();

  RestorePasswordBloc(this._authRepository) : super(InitialRestorePasswordState()) {
    on<SendRestorePasswordEvent>((event, emit) async {
      try {
        emit(LoadingRestorePasswordState());
        await _authRepository.restorePassword(event.email);
        emit(SuccessRestorePasswordState());
      } catch (e, s) {
        print(e);
        print(s);
      }
    });
  }
}
