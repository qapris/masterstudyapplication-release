import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inject/inject.dart';

import './bloc.dart';

@provide
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoState get initialState => InitialVideoState();

  VideoBloc() : super(InitialVideoState()) {
    on<VideoEvent>((event, emit) async => await _videoBloc(event, emit));
  }

  Future<void> _videoBloc(VideoEvent event, Emitter<VideoState> emit) async {
    emit(LoadedVideoState());
  }
}
