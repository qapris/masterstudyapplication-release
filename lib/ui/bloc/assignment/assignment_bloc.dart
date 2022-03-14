import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/models/AssignmentResponse.dart';
import 'package:masterstudy_app/data/repository/assignment_repository.dart';

import './bloc.dart';

@provide
class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository _assignmentRepository;
  final CacheManager cacheManager;

  AssignmentState get initialState => InitialAssignmentState();

  AssignmentBloc(this._assignmentRepository, this.cacheManager) : super(InitialAssignmentState()) {
    on<AssignmentEvent>((event, emit) async {
      await _assignment(event, emit);
    });
  }

  Future<void> _assignment(AssignmentEvent event, Emitter<AssignmentState> emit) async {
    if (event is FetchEvent) {
      try {
        AssignmentResponse assignment = await _assignmentRepository.getAssignmentInfo(event.courseId, event.assignmentId);

        emit(LoadedAssignmentState(assignment));
      } catch (error) {
        if (await cacheManager.isCached(event.courseId)) {
          // emit(CacheWarningAssignmentState());
        }
        print(error);
      }
    }

    if (event is StartAssignmentEvent) {
      try {
        var assignmentStart = await _assignmentRepository.startAssignment(event.courseId, event.assignmentId);
        AssignmentResponse assignment = await _assignmentRepository.getAssignmentInfo(event.courseId, event.assignmentId);

        emit(LoadedAssignmentState(assignment));
      } catch (error) {
        print(error);
      }
    }

    if (event is AddAssignmentEvent) {
      try {
        int course_id = event.courseId;
        int user_assignment_id = event.userAssignmentId;
        if (event.files != null && event.files.isNotEmpty) {
          event.files.forEach((elem) {
            var uploadFile = _assignmentRepository.uploadAssignmentFile(course_id, user_assignment_id, elem);
            print(uploadFile);
          });
        }

        var assignmentAdd = await _assignmentRepository.addAssignment(event.courseId, event.userAssignmentId, event.content);

        AssignmentResponse assignment = await _assignmentRepository.getAssignmentInfo(event.courseId, event.assignmentId);

        emit(LoadedAssignmentState(assignment));
      } catch (error) {
        print(error);
      }
    }
  }
}
