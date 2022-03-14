import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/QuestionAddResponse.dart';
import 'package:masterstudy_app/data/models/QuestionsResponse.dart';
import 'package:masterstudy_app/data/repository/questions_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './bloc.dart';

@provide
class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  final QuestionsRepository _questionsRepository;

  QuestionsState get initialState => InitialQuestionsState();

  QuestionsBloc(this._questionsRepository) : super(InitialQuestionsState()) {
    on<QuestionsEvent>((event, emit) async => await _questionsBloc(event, emit));
  }

  Future<void> _questionsBloc(QuestionsEvent event, Emitter<QuestionsState> emit) async {
    if (event is FetchEvent) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var currentUserId = prefs.get("apiToken").split('|');
        QuestionsResponse questions = await _questionsRepository.getQuestions(event.lessonId, event.page, event.search, "");
        QuestionsResponse questionsMy = await _questionsRepository.getQuestions(event.lessonId, event.page, event.search, currentUserId[0]);

        emit(LoadedQuestionsState(questions, questionsMy));
      } catch (error) {
        print(error);
      }
    }

    if (event is MyQuestionAddEvent) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var currentUserId = prefs.get("apiToken").split('|');

        QuestionAddResponse addAnswer = await _questionsRepository.addQuestion(event.lessonId, event.comment, event.parent);
        QuestionsResponse questionsMy = await _questionsRepository.getQuestions(event.lessonId, 1, "", currentUserId[0]);

        emit(LoadedQuestionsState(event.questionsResponse, questionsMy));
      } catch (error) {
        print(error);
      }
    }
  }
}
