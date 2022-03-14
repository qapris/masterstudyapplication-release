import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/ui/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

class AppInterceptors extends Interceptor {
  Future<dynamic> onRequests(RequestOptions options) async {
    if (options.headers.containsKey("requirestoken")) {
      //remove the auxiliary header
      options.headers.remove("requirestoken");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var header = prefs.get("apiToken");
      // options.headers.addAll({"token": "$header"});
      options.headers.addAll({"token": "105419|c30c4463a0acdac3a45fce72e764bcec"});

      return options;
    }
    return options;
  }

  @override
  Future<dynamic> onErrors(DioError err) async {
    if (err.response != null && err.response?.statusCode != null && err.response?.statusCode == 401) {
      (await CacheManager()).cleanCache();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("apiToken", "");
      navigatorKey.currentState?.pushNamed(SplashScreen.routeName);
    }
    return err;
  }

  Future<dynamic> onResponses(Response response) async {
    return response;
  }
}
