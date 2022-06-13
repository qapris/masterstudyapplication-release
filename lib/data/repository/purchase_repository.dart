import 'package:masterstudy_app/data/models/AddToCartResponse.dart';
import 'package:masterstudy_app/data/models/OrdersResponse.dart';
import 'package:masterstudy_app/data/models/purchase/UserPlansResponse.dart';
import 'package:masterstudy_app/data/network/api_provider.dart';

import '../models/purchase/AllPlansResponse.dart';

abstract class PurchaseRepository {
  Future<UserPlansResponse?> getUserPlans(int courseId);

  Future<List<AllPlansBean>> getPlans({int courseId});

  Future<OrdersResponse> getOrders();

  Future<AddToCartResponse> addToCart(int courseId);

  Future usePlan(int courseId, int subscriptionId);
}

class PurchaseRepositoryImpl extends PurchaseRepository {
  final UserApiProvider _apiProvider;

  PurchaseRepositoryImpl(this._apiProvider);

  @override
  Future<UserPlansResponse?> getUserPlans(int courseId) {
    return _apiProvider.getUserPlans(courseId);
  }

  @override
  Future<List<AllPlansBean>> getPlans({dynamic courseId}) async {
    var response = await _apiProvider.getPlans(courseId);
    return response.plans;
  }

  @override
  Future<OrdersResponse> getOrders() {
    return _apiProvider.getOrders();
  }

  @override
  Future<AddToCartResponse> addToCart(int courseId) async {
    var response = await _apiProvider.addToCart(courseId);
    return response;
  }

  @override
  Future usePlan(int courseId, int subscriptionId) {
    return _apiProvider.usePlan(courseId, subscriptionId);
  }
}
