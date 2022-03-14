import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';

import './bloc.dart';

@provide
class ProfileAssignmentBloc extends Bloc<ProfileAssignmentEvent, ProfileAssignmentState> {
  ProfileAssignmentState get initialState => InitialProfileAssignmentState();

  ProfileAssignmentBloc() : super(InitialProfileAssignmentState()) {
    on<ProfileAssignmentEvent>((event, emit) async => await _profileAssignment(event, emit));
  }

  Future<void> _profileAssignment(ProfileAssignmentEvent event, Emitter<ProfileAssignmentState> emit) async {}
}
