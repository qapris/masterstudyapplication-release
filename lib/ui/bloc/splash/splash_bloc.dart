import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/AppSettings.dart';
import 'package:masterstudy_app/data/network/api_provider.dart';
import 'package:masterstudy_app/data/repository/auth_repository.dart';
import 'package:masterstudy_app/data/repository/home_repository.dart';
import 'package:masterstudy_app/main.dart';
import '../../../data/utils.dart';
import './bloc.dart';

@provide
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository _authRepository;
  final HomeRepository _homeRepository;
  final UserApiProvider _apiProvider;

  SplashState get initialState => InitialSplashState();

  SplashBloc(this._authRepository, this._homeRepository, this._apiProvider) : super(InitialSplashState()) {
    on<CheckAuthSplashEvent>((event, emit) async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool signed = await _authRepository.isSigned();
      emit(InitialSplashState());
      if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
        try {
          for (var key in preferences!.getKeys()) {
            if (key.contains('main_color')) {
              preferences!.remove(key);
            }
          }

          AppSettings appSettings = await _homeRepository.getAppSettings();

          _homeRepository.saveLocal(appSettings);

          try {
            var locale = await _apiProvider.getLocalization();

            _homeRepository.saveLocalizationLocal(locale);

            localizations?.saveCustomLocalization(locale);
          } catch (e) {}

          emit(CloseSplash(signed, appSettings));
        } catch (e, s) {
          print(e);
          print(s);
        }
      } else {
        try {
          var locale = await _homeRepository.getAllLocalizationLocal();
          localizations?.saveCustomLocalization(locale);
        } catch (e) {
          log(e.toString());
        }

        List<AppSettings> appSettingLocal = await _homeRepository.getAppSettingsLocal();

        emit(CloseSplash(signed, appSettingLocal.first));
      }
    });
  }
}
