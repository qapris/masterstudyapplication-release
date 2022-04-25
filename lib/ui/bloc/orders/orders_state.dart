import 'package:masterstudy_app/data/models/OrdersResponse.dart';
import 'package:meta/meta.dart';

@immutable
abstract class OrdersState {}

class InitialOrdersState extends OrdersState {}

class EmptyOrdersState extends OrdersState {}

class EmptyMembershipsState extends OrdersState {}

class LoadedOrdersState extends OrdersState{
  final OrdersResponse orders;

  LoadedOrdersState(this.orders);
}
