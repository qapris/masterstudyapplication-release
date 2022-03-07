import 'package:meta/meta.dart';

@immutable
abstract class RestorePasswordState {}
class InitialRestorePasswordState extends RestorePasswordState{}
class LoadingRestorePasswordState extends RestorePasswordState{}
class SuccessRestorePasswordState extends RestorePasswordState{}