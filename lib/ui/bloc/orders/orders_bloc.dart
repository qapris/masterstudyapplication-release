import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/purchase_repository.dart';
import 'package:masterstudy_app/ui/bloc/orders/orders_event.dart';
import 'orders_state.dart';

@provide
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final PurchaseRepository _repository;

  OrdersState get initialState => InitialOrdersState();

  OrdersBloc(this._repository) : super(InitialOrdersState()) {
    on<FetchEvent>((event, emit) async {
      try {
        var orders = await _repository.getOrders();

        if (orders.posts.isEmpty && orders.memberships.isEmpty) {
          emit(EmptyOrdersState());
          emit(EmptyMembershipsState());
        } else if (orders.posts.isNotEmpty && orders.memberships.isEmpty) {
          emit(EmptyMembershipsState());
          emit(LoadedOrdersState(orders));
        } else if (orders.posts.isEmpty && orders.memberships.isNotEmpty) {
          emit(EmptyOrdersState());
          emit(LoadedOrdersState(orders));
        } else {
          emit(LoadedOrdersState(orders));
        }
      } catch (e, s) {
        print(e);
        print(s);
      }
    });
  }
}
