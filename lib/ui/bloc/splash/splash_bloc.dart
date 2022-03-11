import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/AppSettings.dart';
import 'package:masterstudy_app/data/network/api_provider.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';
import 'package:masterstudy_app/data/repository/home_repository.dart';
import 'package:masterstudy_app/main.dart';
import './bloc.dart';

@provide
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository _repository;
  final HomeRepository _homeRepository;
  final UserApiProvider _apiProvider;

  SplashState get initialState => InitialSplashState();

  SplashBloc(this._repository, this._homeRepository, this._apiProvider) : super(InitialSplashState()) {
    on<CheckAuthSplashEvent>((event, emit) async {
      await _splash(event, emit);
    });
  }

  Future<void> _splash(CheckAuthSplashEvent event, Emitter<SplashState> emit) async {
    emit(InitialSplashState());
    bool signed = await _repository.isSigned();
    try {
      AppSettings appSettings = await _homeRepository.getAppSettings();
      try {
        var locale = await _apiProvider.getLocalization();
        localizations.saveCustomLocalization(locale);
      } catch (e) {
        print(e);
      }

      emit(CloseSplash(signed, appSettings));
    } catch (e, s) {
      AppSettings appSettings = await _homeRepository.getAppSettings();
      emit(CloseSplash(signed, appSettings));

      print(e);
      print(s);
    }
  }
}
