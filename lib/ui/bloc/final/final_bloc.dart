
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/models/FinalResponse.dart';
import 'package:masterstudy_app/data/repository/final_repository.dart';

import './bloc.dart';

@provide
class FinalBloc extends Bloc<FinalEvent, FinalState> {
  final FinalRepository _finalRepository;
  final CacheManager cacheManager;

  FinalState get initialState => InitialFinalState();

  FinalBloc(this._finalRepository, this.cacheManager) : super(InitialFinalState()) {
    on<FetchEvent>((event, emit) async {
      try {
        FinalResponse response = await _finalRepository.getCourseResults(event.courseId);

        emit(LoadedFinalState(response));
      } catch (error) {
        if (await cacheManager.isCached(event.courseId)) {
          emit(CacheWarningState());
        }
        print('Final Page Error');
        print(error);
      }
    });
  }
}
