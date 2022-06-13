import 'package:meta/meta.dart';

import '../../../data/models/purchase/AllPlansResponse.dart';

@immutable
abstract class PlansState {}

class InitialPlansState extends PlansState {}

class LoadedPlansState extends PlansState {
  final List<AllPlansBean> plans;

  LoadedPlansState(this.plans);
}

