import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';
import './bloc.dart';

@provide
class LessonZoomBloc extends Bloc<LessonZoomEvent, LessonZoomState> {
  final LessonRepository _lessonRepository;

  LessonZoomState get initialState => InitialLessonZoomState();

  LessonZoomBloc(this._lessonRepository) : super(InitialLessonZoomState()) {
    on<FetchEvent>((event, emit) async {
      try {
        LessonResponse response = await _lessonRepository.getLesson(event.courseId, event.lessonId);

        emit(LoadedLessonZoomState(response));
      } on DioError catch (e) {
        log(e.response.toString());
      }
    });

    on<CompleteLessonEvent>((event, emit) async {
      try {
        var response = await _lessonRepository.completeLesson(event.courseId, event.lessonId);
      } catch (e, s) {
        print(e);
        print(s);
      }
    });
  }
}
