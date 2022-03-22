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

var dio = Dio();

late SharedPreferences preferences;


AndroidDeviceInfo? androidInfo;
IosDeviceInfo? iosDeviceInfo;

String? appLogoUrl;
Directory? appDocDir;

