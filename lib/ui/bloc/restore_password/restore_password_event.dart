import 'package:meta/meta.dart';

@immutable
abstract class RestorePasswordEvent {}

class SendRestorePasswordEvent extends RestorePasswordEvent{
  final email;

  SendRestorePasswordEvent(this.email);
}