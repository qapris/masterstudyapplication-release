import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/QuestionAddResponse.dart';
import 'package:masterstudy_app/data/repository/questions_repository.dart';

import './bloc.dart';

@provide
class QuestionAskBloc extends Bloc<QuestionAskEvent, QuestionAskState> {
  final QuestionsRepository _questionsRepository;

  QuestionAskState get initialState => InitialQuestionAskState();

  QuestionAskBloc(this._questionsRepository) : super(InitialQuestionAskState()) {
    on<QuestionAskEvent>((event, emit) async => await _questionBloc(event, emit));
  }

  Future<void> _questionBloc(QuestionAskEvent event, Emitter<QuestionAskState> emit) async {
    if (event is QuestionAddEvent) {
      try {
        QuestionAddResponse addAnswer = await _questionsRepository.addQuestion(event.lessonId, event.comment, 0);
        emit(QuestionAddedState(addAnswer));
      } catch (error) {
        print(error);
      }
    }

    emit(LoadedQuestionAskState());
  }
}
