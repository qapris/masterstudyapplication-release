import 'package:masterstudy_app/data/models/AppSettings.dart';
import 'package:meta/meta.dart';

@immutable
abstract class HomeEvent {}

class FetchEvent extends HomeEvent {}

