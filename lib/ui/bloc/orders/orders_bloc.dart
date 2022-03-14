import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/purchase_repository.dart';

import './bloc.dart';

@provide
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final PurchaseRepository _repository;

  OrdersState get initialState => InitialOrdersState();

  OrdersBloc(this._repository) : super(InitialOrdersState()) {
    on<OrdersEvent>((event, emit) async => await _ordersBloc(event, emit));
  }

  Future<void> _ordersBloc(OrdersEvent event, Emitter<OrdersState> emit) async {
    if (event is FetchEvent) {
      try {
        var orders = await _repository.getOrders();
        if (orders != null && orders.isNotEmpty) {
          emit(LoadedOrdersState(orders));
        } else
          emit(EmptyOrdersState());
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }
}
