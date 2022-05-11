import 'package:meta/meta.dart';

@immutable
abstract class SearchDetailEvent {}

class FetchEvent extends SearchDetailEvent {
  final String query;
  final dynamic categoryId;

  FetchEvent(this.query, this.categoryId);
}
