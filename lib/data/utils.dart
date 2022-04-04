import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/AppSettings.dart';

extension QueryParameterAdd on Map {
  addParam(key, value) {
    if (value != null) {
      this[key] = value;
    }
  }
}
List<dynamic> record = [];
List<Map<String, int>> recordMap = [];


var dio = Dio();

late SharedPreferences preferences;

late Connectivity connectivity;

///Timer
late Timer timer;

///Hive
var db;

AndroidDeviceInfo? androidInfo;
IosDeviceInfo? iosDeviceInfo;

String? appLogoUrl;
Directory? appDocDir;

///URL
const BASE_URL = "http://ms.stylemix.biz";
const String apiEndpoint = BASE_URL + "/wp-json/ms_lms/v1/";
