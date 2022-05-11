import 'dart:convert';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/utils.dart';
import '../models/account.dart';

@provide
@singleton
class AccountLocalStorage {
  List<Account> getAccountLocal() {
    try {
      List<String>? cached = preferences?.getStringList('accountLocal');
      cached ??= [];

      return cached.map((json) => Account.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      throw Exception();
    }
  }

  void saveAccountLocal(Account account) {
    String json = jsonEncode(account.toJson());

    List<String>? cached = preferences?.getStringList('accountLocal');

    cached ??= [];

    cached = [];
    cached.add(json);

    preferences?.setStringList('accountLocal', cached);
  }
}
