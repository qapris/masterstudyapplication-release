// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return AuthResponse(
    json['token'] as String,
  );
}

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) => <String, dynamic>{
      'token': instance.token,
    };

ChangePasswordResponse _$ChangePasswordResponseFromJson(Map<String, dynamic> json) {
  return ChangePasswordResponse(
    json['modified'],
    json['values'],
  );
}

Map<String, dynamic> _$ChangePasswordResponseToJson(ChangePasswordResponse instance) => <String, dynamic>{
      'modified': instance.modified,
      'values': instance.values,
    };
