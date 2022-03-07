import 'package:json_annotation/json_annotation.dart';

part 'ReviewAddResponse.g.dart';

@JsonSerializable()
class ReviewAddResponse {
  bool error;
  String status;
  String message;

  ReviewAddResponse({required this.error, required this.status, required this.message});

  factory ReviewAddResponse.fromJson(Map<String, dynamic> json) => _$ReviewAddResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewAddResponseToJson(this);
}
