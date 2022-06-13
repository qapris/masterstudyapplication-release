import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/purchase_repository.dart';
import './bloc.dart';

@provide
class PlansBloc extends Bloc<PlansEvent, PlansState> {
  final PurchaseRepository _repository;

  PlansState get initialState => InitialPlansState();

  PlansBloc(this._repository) : super(InitialPlansState()) {
    on<FetchEvent>((event, emit) async {
      var response = await _repository.getPlans();
      emit(LoadedPlansState(response));
    });
  }
}
