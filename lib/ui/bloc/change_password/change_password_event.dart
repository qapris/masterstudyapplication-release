import 'package:meta/meta.dart';

@immutable
abstract class ChangePasswordEvent {}

class SendChangePasswordEvent extends ChangePasswordEvent{
  final oldPassword;
  final newPassword;

  SendChangePasswordEvent(this.oldPassword,this.newPassword);
}