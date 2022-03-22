import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/lesson_video/bloc.dart';
import 'package:masterstudy_app/ui/screens/assignment/assignment_screen.dart';
import 'package:masterstudy_app/ui/screens/final/final_screen.dart';
import 'package:masterstudy_app/ui/screens/lesson_stream/lesson_stream_screen.dart';
import 'package:masterstudy_app/ui/screens/questions/questions_screen.dart';
import 'package:masterstudy_app/ui/screens/quiz_lesson/quiz_lesson_screen.dart';
import 'package:masterstudy_app/ui/screens/text_lesson/text_lesson_screen.dart';
import 'package:masterstudy_app/ui/screens/user_course_locked/user_course_locked_screen.dart';
import 'package:masterstudy_app/ui/screens/video_screen/video_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../data/utils.dart';
import '../../../main.dart';

class LessonVideoScreenArgs {
  final int courseId;
  final int lessonId;
  final String authorAva;
  final String authorName;
  final bool hasPreview;
  final bool trial;

  LessonVideoScreenArgs(this.courseId, this.lessonId, this.authorAva, this.authorName, this.hasPreview, this.trial);
}

class LessonVideoScreen extends StatelessWidget {
  static const routeName = 'lessonVideoScreen';
  final LessonVideoBloc _bloc;

  const LessonVideoScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final LessonVideoScreenArgs args = ModalRoute.of(context)?.settings.arguments as LessonVideoScreenArgs;

    return BlocProvider<LessonVideoBloc>(
      create: (c) => _bloc,
      child: _LessonVideoScreenWidget(
        args.courseId,
        args.lessonId,
        args.authorAva,
        args.authorName,
        args.hasPreview,
        args.trial,
      ),
    );
  }
}

class _LessonVideoScreenWidget extends StatefulWidget {
  final int courseId;
  final int lessonId;
  final String authorAva;
  final String authorName;
  final bool hasPreview;
  final bool trial;

  const _LessonVideoScreenWidget(this.courseId, this.lessonId, this.authorAva, this.authorName, this.hasPreview, this.trial);

  @override
  State<StatefulWidget> createState() => _LessonVideoScreenState();
}

class _LessonVideoScreenState extends State<_LessonVideoScreenWidget> {
  late LessonVideoBloc _bloc;
  late VideoPlayerController _controller;
  late YoutubePlayerController _youtubePlayerController;
  late VoidCallback listener;

  bool completed = false;
  bool video = true;
  bool videoPlayed = false;
  bool videoLoaded = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<LessonVideoBloc>(context)..add(FetchEvent(widget.courseId, widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonVideoBloc, LessonVideoState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: HexColor.fromHex("#151A25"),
          appBar: AppBar(
            backgroundColor: HexColor.fromHex("#273044"),
            title: _buildTitle(state),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: _buildBody(state),
            ),
          ),
          bottomNavigationBar: (!widget.trial) ? null : _buildBottom(state),
        );
      },
    );
  }

  ///Title AppBar
  _buildTitle(state) {
    if (state is InitialLessonVideoState) {
      return const SizedBox();
    }

    if (state is LoadedLessonVideoState) {
      var item = state.lessonResponse;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //Title and Label Course
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.section?.number,
                  textScaleFactor: 1.0,
                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                ),
                Flexible(
                  child: Text(
                    item.section?.label,
                    textScaleFactor: 1.0,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Question Icon
          (widget.hasPreview)
              ? Center()
              : SizedBox(
                  width: 40,
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                      backgroundColor: MaterialStateProperty.all(HexColor.fromHex("#3E4555")),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        QuestionsScreen.routeName,
                        arguments: QuestionsScreenArgs(widget.lessonId, 1),
                      );
                    },
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          "assets/icons/question_icon.svg",
                          color: Colors.white,
                        )),
                  ),
                )
        ],
      );
    }
  }

  ///Body of Video Lesson
  _buildBody(state) {
    if (state is LoadedLessonVideoState) {
      var item = state.lessonResponse;
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //Text "Video $NUMBER"
          Padding(
            padding: EdgeInsets.only(top: 10.0, right: 7.0, bottom: 10.0, left: 7.0),
            child: Text(
              "Video ${item.section?.index}",
              textScaleFactor: 1.0,
              style: TextStyle(color: HexColor.fromHex("#FFFFFF")),
            ),
          ),
          //Title of Video Lesson
          Padding(
            padding: EdgeInsets.only(top: 20.0, right: 7.0, bottom: 20.0, left: 7.0),
            child: Html(
              data: item.title,
              style: {'body': Style(fontSize: FontSize(34.0), fontWeight: FontWeight.w700, color: HexColor.fromHex("#FFFFFF"))},
            ),
          ),
          //Video
          Padding(
              padding: EdgeInsets.only(top: 20.0, right: 7.0, bottom: 20.0, left: 7.0),
              child: (item.video != "")
                  ? Container(
                      height: 211.0,
                      child: Stack(
                        children: <Widget>[
                          //Background Photo of Video
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 211.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(item.video_poster),
                              ),
                            ),
                          ),
                          //Button "Play Video"
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 160,
                              height: 50,
                              child: Container(
                                decoration: new BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 10,
                                      // has the effect of softening the shadow
                                      spreadRadius: -2,
                                      // has the effect of extending the shadow
                                      offset: Offset(
                                        0,
                                        // horizontal, move right 10
                                        12.0, // vertical, move down 10
                                      ),
                                    )
                                  ],
                                ),
                                //Button "Play Video"
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                    ),
                                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                                    backgroundColor: MaterialStateProperty.all(HexColor.fromHex("#D7143A")),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pushNamed(
                                      VideoScreen.routeName,
                                      arguments: VideoScreenArgs(item.title, item.video),
                                    );
                                    //_buildVideoPopup(state);
                                    /*if (Platform.isIOS) {
                                      _launchURL(item.video);
                                    } else {
                                      Navigator.of(context).pushNamed(
                                        VideoScreen.routeName,
                                        arguments: VideoScreenArgs(item.title, item.video),
                                      );
                                    }*/
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 0, right: 4.0),
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        localizations.getLocalization("play_video_button"),
                                        textScaleFactor: 1.0,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14.0),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()),
          _buildWebContent(state.lessonResponse.content)
        ],
      );
    }

    if (state is InitialLessonVideoState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  late WebViewController _descriptionWebViewController;
  double? descriptionHeight;

  ///Web Content
  _buildWebContent(String content) {
    if (Platform.isAndroid || Platform.isIOS /*&& (androidInfo?.version.sdkInt == 30 || androidInfo?.version.sdkInt == 31)*/) {
      return Html(
        data: content,
        style: {'body': Style(fontSize: FontSize(14.0), color: Colors.white)},
      );
    }

    double webContainerHeight;
    if (descriptionHeight != null) {
      webContainerHeight = descriptionHeight!;
    } else {
      webContainerHeight = 160;
    }

    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: webContainerHeight),
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          initialUrl: 'data:/text/html;base64, ${base64Encode(const Utf8Encoder().convert(content))}',
          onPageFinished: (some) async {
            double height = double.parse(await _descriptionWebViewController.runJavascriptReturningResult("document.documentElement.scrollHeight;"));
            setState(() {
              descriptionHeight = height;
              print("webview $height");
            });
          },
          onWebViewCreated: (controller) async {
            controller.clearCache();
            this._descriptionWebViewController = controller;
          },
        ));
  }

  ///Bottom Button
  //Bottom button "Complete Lesson" and "arrow"
  _buildBottom(LessonVideoState state) {
    if (state is InitialLessonVideoState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is LoadedLessonVideoState) {
      return Container(
        decoration: BoxDecoration(color: HexColor.fromHex("#273044"), boxShadow: [BoxShadow(color: HexColor.fromHex("#000000").withOpacity(.1), offset: Offset(0, 0), blurRadius: 6, spreadRadius: 2)]),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 35,
                height: 35,
                child: (state.lessonResponse.prev_lesson != "")
                    ? FlatButton(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0), side: BorderSide(color: HexColor.fromHex("#306ECE"))),
                        onPressed: () {
                          switch (state.lessonResponse.prev_lesson_type) {
                            case "video":
                              Navigator.of(context).pushReplacementNamed(
                                LessonVideoScreen.routeName,
                                arguments:
                                    LessonVideoScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName, widget.hasPreview, widget.trial),
                              );
                              break;
                            case "quiz":
                              Navigator.of(context).pushReplacementNamed(
                                QuizLessonScreen.routeName,
                                arguments: QuizLessonScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName),
                              );
                              break;
                            case "assignment":
                              Navigator.of(context).pushReplacementNamed(
                                AssignmentScreen.routeName,
                                arguments: AssignmentScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName),
                              );
                              break;
                            case "stream":
                              Navigator.of(context).pushReplacementNamed(
                                LessonStreamScreen.routeName,
                                arguments: LessonStreamScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName),
                              );
                              break;
                            default:
                              Navigator.of(context).pushReplacementNamed(
                                TextLessonScreen.routeName,
                                arguments: TextLessonScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.prev_lesson)!, widget.authorAva, widget.authorName, widget.hasPreview, widget.trial),
                              );
                          }
                        },
                        padding: EdgeInsets.all(0.0),
                        color: mainColor,
                        hoverColor: secondColor,
                        focusColor: secondColor,
                        child: Icon(
                          Icons.chevron_left,
                          color: HexColor.fromHex("#273044"),
                        ),
                      )
                    : Center(),
              ),
              Expanded(
                flex: 8,
                child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: MaterialButton(
                        height: 50,
                        color: mainColor,
                        onPressed: () {
                          if (state is LoadedLessonVideoState && !state.lessonResponse.completed) {
                            _bloc.add(CompleteLessonEvent(widget.courseId, widget.lessonId));
                            setState(() {
                              completed = true;
                            });
                          }
                        },
                        child: _buildButtonChild(state))),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: FlatButton(
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0), side: BorderSide(color: HexColor.fromHex("#306ECE"))),
                  onPressed: () {
                    if (state.lessonResponse.next_lesson != "") {
                      if (state.lessonResponse.next_lesson_available) {
                        switch (state.lessonResponse.next_lesson_type) {
                          case "video":
                            Navigator.of(context).pushReplacementNamed(
                              LessonVideoScreen.routeName,
                              arguments: LessonVideoScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName, widget.hasPreview, widget.trial),
                            );
                            break;
                          case "quiz":
                            Navigator.of(context).pushReplacementNamed(
                              QuizLessonScreen.routeName,
                              arguments: QuizLessonScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName),
                            );
                            break;
                          case "assignment":
                            Navigator.of(context).pushReplacementNamed(
                              AssignmentScreen.routeName,
                              arguments: AssignmentScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName),
                            );
                            break;
                          case "stream":
                            Navigator.of(context).pushReplacementNamed(
                              LessonStreamScreen.routeName,
                              arguments: LessonStreamScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName),
                            );
                            break;
                          default:
                            Navigator.of(context).pushReplacementNamed(
                              TextLessonScreen.routeName,
                              arguments: TextLessonScreenArgs(widget.courseId, int.tryParse(state.lessonResponse.next_lesson)!, widget.authorAva, widget.authorName, widget.hasPreview, widget.trial),
                            );
                        }
                      } else {
                        Navigator.of(context).pushNamed(
                          UserCourseLockedScreen.routeName,
                          arguments: UserCourseLockedScreenArgs(widget.courseId),
                        );
                      }
                    } else {
                      var future = Navigator.of(context).pushNamed(
                        FinalScreen.routeName,
                        arguments: FinalScreenArgs(widget.courseId),
                      );
                      future.then((value) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  padding: EdgeInsets.all(0.0),
                  color: mainColor,
                  hoverColor: secondColor,
                  focusColor: secondColor,
                  child: Icon(
                    Icons.chevron_right,
                    color: HexColor.fromHex("#273044"),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  ///Widgets inside button "Complete Lesson"
  _buildButtonChild(LessonVideoState state) {
    if (state is InitialLessonVideoState)
      return SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    if (state is LoadedLessonVideoState) {
      Widget icon;
      if (state.lessonResponse.completed || completed) {
        icon = Icon(Icons.check_circle);
      } else {
        icon = Icon(Icons.panorama_fish_eye);
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          icon,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              localizations.getLocalization("complete_lesson_button"),
              textScaleFactor: 1.0,
            ),
          )
        ],
      );
    }
  }

  _launchURL(String url) async {
    await launch(url);
  }
}
