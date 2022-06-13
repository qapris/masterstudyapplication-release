import 'dart:async';

import 'package:dio/dio.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/utils.dart';
import 'package:masterstudy_app/ui/screens/splash/splash_screen.dart';

import '../../../main.dart';

class AppInterceptors extends Interceptor {
  Future<dynamic> onRequests(RequestOptions options) async {
    if (options.headers.containsKey("requirestoken")) {
      //remove the auxiliary header
      options.headers.remove("requirestoken");

      var header = preferences!.getString("apiToken");
      options.headers.addAll({"token": "$header"});

      return options;
    }
    return options;
  }

  @override
  Future<dynamic> onErrors(DioError err) async {
    if (err.response != null && err.response?.statusCode != null && err.response?.statusCode == 401) {
      (await CacheManager()).cleanCache();
      preferences!.setString("apiToken", "");
      navigatorKey.currentState?.pushNamed(SplashScreen.routeName);
    }
    return err;
  }

  Future<dynamic> onResponses(Response response) async {
    return response;
  }
}
