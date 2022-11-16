import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/video/bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:vimeo_player_flutter/vimeo_player_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreenArgs {
  final String? title;
  final String? videoLink;

  VideoScreenArgs(this.title, this.videoLink);
}

class VideoScreen extends StatelessWidget {
  static const routeName = 'videoScreen';
  final VideoBloc _bloc;

  const VideoScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final VideoScreenArgs? args = ModalRoute.of(context)?.settings.arguments as VideoScreenArgs?;

    return BlocProvider<VideoBloc>(create: (c) => _bloc, child: _VideoScreenWidget(args?.title, args?.videoLink));
  }
}

class _VideoScreenWidget extends StatefulWidget {
  final dynamic videoLink;
  final dynamic title;

  const _VideoScreenWidget(this.title, this.videoLink);

  @override
  State<StatefulWidget> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<_VideoScreenWidget> {
  VideoBloc? _bloc;
  late VideoPlayerController _controller;
  YoutubePlayerController? _youtubePlayerController;
  Widget? vimeoPlayer;

  bool video = false;
  bool videoPlayed = false;
  bool videoLoaded = false;
  bool isYoutube = false;

  //Enable orientation
  void _enableRotation() {
    if (isYoutube) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  initState() {
    super.initState();
    _enableRotation();
    _bloc = BlocProvider.of<VideoBloc>(context)..add(FetchEvent(widget.title, widget.videoLink));

    ///Function for check format video and play youtube/vimeo
    var format = widget.videoLink?.split(".");
    if (format?.last == 'mp4') {
      setState(() {
        video = true;
      });
      _controller = VideoPlayerController.network(widget.videoLink)
        ..setLooping(true)
        ..play()
        ..initialize().then((_) {
          setState(() {
            videoLoaded = true;
          });
        });
    } else if (video == false && !widget.videoLink.toString().contains('vimeo')) {
      setState(() {
        isYoutube = true;
      });
      String? videoId = YoutubePlayer.convertUrlToId(widget.videoLink);
      if (videoId != "") {
        _youtubePlayerController = YoutubePlayerController(
          initialVideoId: videoId!,
          flags: YoutubePlayerFlags(
            autoPlay: true,
          ),
        );
      }
    } else if (video == false && widget.videoLink.toString().contains('vimeo')) {
      var convertedVimeoCode = widget.videoLink.toString().replaceAll(new RegExp(r'[^0-9]'), '');
      vimeoPlayer = VimeoPlayer(videoId: convertedVimeoCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: HexColor.fromHex("#000000"),
          appBar: AppBar(
            backgroundColor: HexColor.fromHex("#000000"),
            automaticallyImplyLeading: false,
            //Title
            title: Text(widget.title,
                textScaleFactor: 1.0,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                )),
            actions: <Widget>[
              //Icon Close
              Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15.0),
                child: SizedBox(
                  width: 42,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                      await SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: SafeArea(
            child: OrientationBuilder(builder: (context, orientation) {
              return Padding(
                padding: EdgeInsets.only(top: 0.0, right: 20, bottom: 10, left: 20),
                child: _buildBody(state, orientation),
              );
            }),
          ),
        );
      },
    );
  }

  _buildBody(state, orientation) {
    if (state is LoadedVideoState) {
      return isYoutube
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[loadPlayer(orientation)],
              ),
            )
          : SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[loadPlayer(orientation)],
              ),
            );
    }

    if (state is InitialVideoState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  loadPlayer(orientation) {
    if (video) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Center(
            child: _controller.value.isInitialized
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      SizedBox(
                          width: 42,
                          height: 30,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(0.0),
                              backgroundColor: HexColor.fromHex("#000000"),
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.value.isPlaying ? _controller.pause() : _controller.play();
                              });
                            },

                            child: Icon(
                              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: HexColor.fromHex("#FFFFFF"),
                              size: 24.0,
                            ),
                          ))
                    ],
                  )
                : SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
          ),
        ],
      );
    } else if (widget.videoLink.toString().contains('vimeo')) {
      return orientation == Orientation.portrait
          ? SizedBox(
              width: 400,
              height: 200,
              child: vimeoPlayer!,
            )
          : SizedBox(width: double.infinity, height: MediaQuery.of(context).size.height * (75 / 100), child: vimeoPlayer!);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Center(
            child: YoutubePlayer(
                controller: _youtubePlayerController!,
                showVideoProgressIndicator: true,
                actionsPadding: EdgeInsets.only(left: 16.0),
                bottomActions: [
                  CurrentPosition(),
                  SizedBox(width: 10.0),
                  ProgressBar(isExpanded: true),
                  SizedBox(width: 10.0),
                  RemainingDuration(),
                  FullScreenButton(),
                ],
                onReady: () {}),
          )
        ],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _youtubePlayerController!.dispose();
  }
}
