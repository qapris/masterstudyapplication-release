import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/cache/cache_manager.dart';
import 'package:masterstudy_app/data/repository/lesson_repository.dart';

import './bloc.dart';

@provide
class LessonStreamBloc extends Bloc<LessonStreamEvent, LessonStreamState> {
    final LessonRepository repository;
    final CacheManager cacheManager;

    LessonStreamBloc(this.repository, this.cacheManager) : super(InitialLessonStreamState());

    @override
    LessonStreamState get initialState => InitialLessonStreamState();

    @override
    Stream<LessonStreamState> mapEventToState(
        LessonStreamEvent event,
        ) async* {
        if (event is FetchEvent) {
            try{
                var response = await repository.getLesson(event.courseId, event.lessonId);
                print(response);
                yield LoadedLessonStreamState(response);
            }catch(e,s){

                if(await cacheManager.isCached(event.courseId)){
                    yield CacheWarningLessonStreamState();
                }
                print(e);
                print(s);
            }
        }
    }
}
