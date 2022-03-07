import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';
import 'package:masterstudy_app/ui/bloc/restore_password/bloc.dart';

@provide
class RestorePasswordBloc
    extends Bloc<RestorePasswordEvent, RestorePasswordState> {
  final AuthRepository _authRepository;

  RestorePasswordBloc(this._authRepository): super(InitialRestorePasswordState());

  @override
  RestorePasswordState get initialState => InitialRestorePasswordState();

  @override
  Stream<RestorePasswordState> mapEventToState(
      RestorePasswordEvent event) async* {
    if (event is SendRestorePasswordEvent) {
      try {
        yield LoadingRestorePasswordState();
        await _authRepository.restorePassword(event.email);
        yield SuccessRestorePasswordState();
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }
}
