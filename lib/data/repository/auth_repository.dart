
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/models/auth.dart';
import 'package:masterstudy_app/data/network/api_provider.dart';

import '../utils.dart';

abstract class AuthRepository {
  Future authUser(String login, String password);

  Future register(String login, String email, String password);

  Future restorePassword(String email);

  Future<Response> changePassword(String oldPassword, String newPassword);

  Future demoAuth();

  Future<String> getToken();

  Future<bool> isSigned();

  Future logout();
}

@provide
@singleton
class AuthRepositoryImpl extends AuthRepository {
  final UserApiProvider provider;
  static const tokenKey = "apiToken";

  AuthRepositoryImpl(this.provider);

  Future authUser(String login, String password) async {
    AuthResponse response = await provider.authUser(login, password);

    _saveToken(response.token);
  }

  Future register(String login, String email, String password) async {
    AuthResponse response = await provider.signUpUser(login, email, password);
    _saveToken(response.token);
  }

  Future<String> getToken() {
    return Future.value(preferences!.getString(tokenKey));
  }

  void _saveToken(String token) {
    preferences!.setString(tokenKey, token);
    dio.options.headers.addAll({"token": "$token"});
  }

  Future<bool> isSigned() {
    String? token = preferences!.getString(tokenKey);
    dio.options.headers.addAll({"token": "$token"});
    if(token == null) {
      return Future.value(false);
    }
    if (token.isNotEmpty) return Future.value(true);
    return Future.value(false);
  }

  Future logout() async {
    preferences!.setString("apiToken", "");
    await CacheManager().cleanCache();
  }

  Future demoAuth() async {
    var token = await provider.demoAuth();
    dio.options.headers.addAll({"token": "$token"});
    _saveToken(token);
  }

  Future restorePassword(String email) async {
    await provider.restorePassword(email);
  }

  Future<Response> changePassword(String oldPassword, String newPassword) async {
    return await provider.changePassword(oldPassword,newPassword);
  }
}
