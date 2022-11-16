import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

///Timer
late Timer timer;

///SharedPreferences
late SharedPreferences preferences;

///Platforms
AndroidDeviceInfo? androidInfo;
IosDeviceInfo? iosDeviceInfo;

///App Settings
String? appLogoUrl;
Directory? appDocDir;

///URL
// const BASE_URL = "http://hackedneuralnetwork.com";
// const BASE_URL = "https://tfaseel.com";
const BASE_URL = "https://masterstudy.stylemixthemes.com/academy";
// const BASE_URL = "https://mindbodism.com";
const String apiEndpoint = BASE_URL + "/wp-json/ms_lms/v2/";
