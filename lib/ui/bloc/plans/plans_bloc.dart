import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/purchase_repository.dart';
import './bloc.dart';

@provide
class PlansBloc extends Bloc<PlansEvent, PlansState> {
  final PurchaseRepository _repository;

  PlansState get initialState => InitialPlansState();

  PlansBloc(this._repository) : super(InitialPlansState()) {
    on<PlansEvent>((event, emit) async => await _plans(event, emit));
  }

  Future<void> _plans(PlansEvent event, Emitter<PlansState> emit) async {
    if (event is FetchEvent) {
      var response = await _repository.getPlans();
      emit(LoadedPlansState(response));
    }
  }
}
