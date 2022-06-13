import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';
import './bloc.dart';

@provide
class LessonVideoBloc extends Bloc<LessonVideoEvent, LessonVideoState> {
  final LessonRepository _lessonRepository;

  LessonVideoState get initialState => InitialLessonVideoState();

  LessonVideoBloc(this._lessonRepository) : super(InitialLessonVideoState()) {
    on<FetchEvent>((event, emit) async {
      try {
        LessonResponse response = await _lessonRepository.getLesson(event.courseId, event.lessonId);

        emit(LoadedLessonVideoState(response));
      } on DioError {}
    });

    on<CompleteLessonEvent>((event, emit) async {
      try {
        var response = await _lessonRepository.completeLesson(event.courseId, event.lessonId);
      } catch (e, s) {
        log(e.toString());
        print(e);
        print(s);
      }
    });
  }
}
