import 'package:meta/meta.dart';

@immutable
abstract class ChangePasswordState {}

class InitialChangePasswordState extends ChangePasswordState {}

class LoadingChangePasswordState extends ChangePasswordState {}

class SuccessChangePasswordState extends ChangePasswordState {}

// ignore: must_be_immutable
class ErrorChangePasswordState extends ChangePasswordState {
  dynamic message;

  ErrorChangePasswordState(this.message);
}
