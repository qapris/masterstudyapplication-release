import 'package:meta/meta.dart';

@immutable
abstract class ChangePasswordState {}

class InitialChangePasswordState extends ChangePasswordState {}

class LoadingChangePasswordState extends ChangePasswordState {}

class SuccessChangePasswordState extends ChangePasswordState {}

class ErrorChangePasswordState extends ChangePasswordState {
  final dynamic message;

  ErrorChangePasswordState(this.message);
}
