import 'package:dio/dio.dart';

class LoggingInterceptors extends Interceptor {
  Future<dynamic> onRequests(RequestOptions options) async {
    print("--> ${options.method != null ? options.method.toUpperCase() : 'METHOD'} ${"" + (options.baseUrl ) + (options.path)}");
    print("Headers:");
    options.headers.forEach((k, v) => print('$k: $v'));
    print("queryParameters:");
    options.queryParameters.forEach((k, v) => print('$k: $v'));
    if (options.data != null) {
      print("Body: ${options.data}");
    }
    print("--> END ${options.method != null ? options.method.toUpperCase() : 'METHOD'}");

    return options;
  }

  Future<dynamic> onErrors(DioError dioError) async {
    print("<-- ${dioError.message} ${(dioError.response?.data != null ? (dioError.response?.data.baseUrl + dioError.response?.data.path) : 'URL')}");
    print("${dioError.response != null ? dioError.response?.data : 'Unknown Error'}");
    print("<-- End error");
    return dioError;
  }

  Future<dynamic> onResponses(Response response) async {
    print("<-- ${response.statusCode} ${(response.data != null ? (response.data.baseUrl + response.data.path) : 'URL')}");
    print("Headers:");
    response.headers.forEach((k, v) => print('$k: $v'));
    print("Response: ${response.data}");
    print("<-- END HTTP");
    return response;
  }
}
