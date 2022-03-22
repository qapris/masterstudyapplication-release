import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:meta/meta.dart';


import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';

import './bloc.dart';

@provide
class LessonZoomBloc extends Bloc<LessonZoomEvent, LessonZoomState> {
  final LessonRepository _lessonRepository;

  LessonZoomState get initialState => InitialLessonZoomState();

  LessonZoomBloc(this._lessonRepository) : super(InitialLessonZoomState()) {
    on<LessonZoomEvent>((event, emit) async {
      await _lessonZoom(event, emit);
    });
  }

  Future<void> _lessonZoom(LessonZoomEvent event, Emitter<LessonZoomState> emit) async {
    if (event is FetchEvent) {
      try {
        LessonResponse response = await _lessonRepository.getLesson(event.courseId, event.lessonId);

        emit(LoadedLessonZoomState(response));
      } on DioError catch(e) {
      }
    } else if (event is CompleteLessonEvent) {
      try {
        var response = await _lessonRepository.completeLesson(event.courseId, event.lessonId);
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }
}






