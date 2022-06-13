import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_downloader/image_downloader.dart';
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
import 'package:path_provider/path_provider.dart';
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
  late WebViewController _descriptionWebViewController;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  final GlobalKey webViewKey = GlobalKey();

  bool completed = false;
  bool video = true;
  bool videoPlayed = false;
  bool videoLoaded = false;
  bool isLoading = false;
  bool isLoadingImg = false;
  int _progressImg = 0;
  double? descriptionHeight;
  var progress = '';
  List<dynamic> progressImgList = [];
  Map<String, dynamic>? progressMap = {};
  Map<String, dynamic>? progressMapImg = {};
  Widget? svgIcon;

  void _enableRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true, mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    super.initState();
    _enableRotation();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _bloc = BlocProvider.of<LessonVideoBloc>(context)..add(FetchEvent(widget.courseId, widget.lessonId));
    ImageDownloader.callback(onProgressUpdate: (String? imageId, int progress) {
      setState(() {
        _progressImg = progress;
      });

      if (progress == 100) {
        setState(() {
          isLoadingImg = false;
        });
      }
    });
  }

  double progressWeb = 0;
  bool _isLoading = false;

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
          body: Padding(
            padding: EdgeInsets.only(top: 10.0, right: 10, bottom: 20, left: 10),
            child: _buildBody(state),
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
      if (_isLoading) {
        return Center(child: CircularProgressIndicator());
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              padding: EdgeInsets.only(top: 10.0, right: 7.0, bottom: 0.0, left: 7.0),
              child: Html(
                data: item.title,
                style: {'body': Style(fontSize: FontSize(24.0), fontWeight: FontWeight.w700, color: HexColor.fromHex("#FFFFFF"))},
              ),
            ),
            //Video
            Padding(
                padding: EdgeInsets.only(top: 10.0, right: 7.0, bottom: 0.0, left: 7.0),
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
                                width: 1600,
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
                                          localizations!.getLocalization("play_video_button"),
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
            //WebView
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUserScripts: UnmodifiableListView<UserScript>([]),
                initialData: InAppWebViewInitialData(data: state.lessonResponse.content),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    preferredContentMode: UserPreferredContentMode.RECOMMENDED,
                  ),
                ),
                androidOnPermissionRequest: (controller, origin, resources) async {
                  return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                },
                onLoadStop: (controller, url) async {},
                onWebViewCreated: (controller) async {
                  this.webViewController = controller;
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    progressWeb = progress / 100;
                  });
                },
              ),
            ),
            //Materials "Text"
            state.lessonResponse.materials.isNotEmpty
                ? Text(
                    localizations!.getLocalization("materials"),
                    textScaleFactor: 1.0,
                    style: TextStyle(color: HexColor.fromHex("#FFFFFF"), fontSize: 24, fontWeight: FontWeight.w700),
                  )
                : const SizedBox(),
            //Materials
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: state.lessonResponse.materials.length,
                itemBuilder: (BuildContext ctx, int index) {
                  var item = state.lessonResponse.materials[index];
                  switch (item!.type) {
                    case 'audio':
                      svgIcon = SvgPicture.asset('assets/icons/audio.svg', color: Colors.white);
                      break;
                    case 'avi':
                      svgIcon = SvgPicture.asset('assets/icons/avi.svg', color: Colors.white);
                      break;
                    case 'doc':
                      svgIcon = SvgPicture.asset('assets/icons/doc.svg', color: Colors.white);
                      break;
                    case 'docx':
                      svgIcon = SvgPicture.asset('assets/icons/docx.svg', color: Colors.white);
                      break;
                    case 'gif':
                      svgIcon = SvgPicture.asset('assets/icons/gif.svg', color: Colors.white);
                      break;
                    case 'jpeg':
                      svgIcon = SvgPicture.asset('assets/icons/jpeg.svg', color: Colors.white);
                      break;
                    case 'jpg':
                      svgIcon = SvgPicture.asset('assets/icons/jpg.svg', color: Colors.white);
                      break;
                    case 'mov':
                      svgIcon = SvgPicture.asset('assets/icons/mov.svg', color: Colors.white);
                      break;
                    case 'mp3':
                      svgIcon = SvgPicture.asset('assets/icons/mp3.svg', color: Colors.white);
                      break;
                    case 'mp4':
                      svgIcon = SvgPicture.asset('assets/icons/mp4.svg', color: Colors.white);
                      break;
                    case 'pdf':
                      svgIcon = SvgPicture.asset('assets/icons/pdf.svg', color: Colors.white);
                      break;
                    case 'png':
                      svgIcon = SvgPicture.asset('assets/icons/png.svg', color: Colors.white);
                      break;
                    case 'ppt':
                      svgIcon = SvgPicture.asset('assets/icons/ppt.svg', color: Colors.white);
                      break;
                    case 'pptx':
                      svgIcon = SvgPicture.asset('assets/icons/pptx.svg', color: Colors.white);
                      break;
                    case 'psd':
                      svgIcon = SvgPicture.asset('assets/icons/psd.svg', color: Colors.white);
                      break;
                    case 'txt':
                      svgIcon = SvgPicture.asset('assets/icons/txt.svg', color: Colors.white);
                      break;
                    case 'xls':
                      svgIcon = SvgPicture.asset('assets/icons/xls.svg', color: Colors.white);
                      break;
                    case 'xlsx':
                      svgIcon = SvgPicture.asset('assets/icons/xlsx.svg', color: Colors.white);
                      break;
                    case 'zip':
                      svgIcon = SvgPicture.asset('assets/icons/zip.svg', color: Colors.white);
                      break;
                    default:
                      svgIcon = SvgPicture.asset('assets/icons/txt.svg', color: Colors.white);
                  }
                  return Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 50, height: 30, child: svgIcon!),
                        //Materials Label
                        Expanded(
                          child: Text(
                            '${item.label}.${item.type} (${item.size})',
                            style: TextStyle(
                              color: HexColor.fromHex("#FFFFFF"),
                              fontSize: 14,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: isLoading
                              ? () {
                                  log('1'.toString());
                                }
                              : () async {
                                  var cyrillicSymbols = RegExp('[а-яёА-ЯЁ]');
                                  bool isSymbols = cyrillicSymbols.hasMatch(item.url);
                                  String? dir;

                                  if (Platform.isAndroid) {
                                    dir = (await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS));
                                  } else if (Platform.isIOS) {
                                    dir = (await getApplicationDocumentsDirectory()).path;
                                  }

                                  if (item.url.toString().contains('jpeg') || item.url.toString().contains('png') || item.url.toString().contains('jpg')) {
                                    if (Platform.isIOS && isSymbols) {
                                      AlertDialog alert = AlertDialog(
                                        title: Text('Error image', textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
                                        content: Text(
                                          "Photo format error",
                                          textScaleFactor: 1.0,
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            child: Text(
                                              'Ok',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                            ),
                                          )
                                        ],
                                      );

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    } else {
                                      setState(() {
                                        isLoadingImg = true;
                                        progressMapImg!['item_url'] = item.url;
                                      });

                                      var imageId = await ImageDownloader.downloadImage(item.url);

                                      if (imageId == null) {
                                        return print('Error');
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                      progressMap!['item_url'] = item.url;
                                    });

                                    String fileName = item.url.substring(item.url.lastIndexOf("/") + 1);

                                    String fullPath = dir! + '/$fileName';

                                    Response response = await dio.get(
                                      item.url,
                                      onReceiveProgress: (received, total) {
                                        setState(() {
                                          progress = ((received / total * 100).toStringAsFixed(0) + '%');
                                        });
                                        progressMap!.addParam('progress', progress);
                                      },

                                      //Received data with List<int>
                                      options: Options(
                                        responseType: ResponseType.bytes,
                                        followRedirects: false,
                                      ),
                                    );

                                    File file = File(fullPath);
                                    var raf = file.openSync(mode: FileMode.write);
                                    raf.writeFromSync(response.data);
                                    await raf.close();

                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                },
                          icon: isLoadingImg && item.url == progressMapImg!['item_url'] || isLoading && item.url == progressMap!['item_url']
                              ? SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  _progressImg == 100 && item.url == progressMapImg!['item_url'] || progress == '${100}%' && item.url == progressMap!['item_url'] ? Icons.check : Icons.download,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ),
                  );
                })
          ],
        );
      }
    }

    if (state is InitialLessonVideoState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  ///Web Content
  _buildWebContent(String content, state) {
    return Column(
      children: [
        Expanded(
          child: InAppWebView(
            key: webViewKey,
            initialUserScripts: UnmodifiableListView<UserScript>([]),
            initialData: InAppWebViewInitialData(data: content),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                preferredContentMode: UserPreferredContentMode.RECOMMENDED,
              ),
            ),
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
            },
            onLoadStop: (controller, url) async {},
            onWebViewCreated: (controller) async {
              this.webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                progressWeb = progress / 100;
              });
            },
          ),
        ),

        //Materials "Text"
        Text(
          localizations!.getLocalization("materials"),
          textScaleFactor: 1.0,
          style: TextStyle(color: HexColor.fromHex("#FFFFFF"), fontSize: 34, fontWeight: FontWeight.w700),
        ),

        //Materials
        Container(
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: state.lessonResponse.materials.length,
              itemBuilder: (BuildContext ctx, int index) {
                var item = state.lessonResponse.materials[index];
                switch (item!.type) {
                  case 'audio':
                    svgIcon = SvgPicture.asset('assets/icons/audio.svg', color: Colors.white);
                    break;
                  case 'avi':
                    svgIcon = SvgPicture.asset('assets/icons/avi.svg', color: Colors.white);
                    break;
                  case 'doc':
                    svgIcon = SvgPicture.asset('assets/icons/doc.svg', color: Colors.white);
                    break;
                  case 'docx':
                    svgIcon = SvgPicture.asset('assets/icons/docx.svg', color: Colors.white);
                    break;
                  case 'gif':
                    svgIcon = SvgPicture.asset('assets/icons/gif.svg', color: Colors.white);
                    break;
                  case 'jpeg':
                    svgIcon = SvgPicture.asset('assets/icons/jpeg.svg', color: Colors.white);
                    break;
                  case 'jpg':
                    svgIcon = SvgPicture.asset('assets/icons/jpg.svg', color: Colors.white);
                    break;
                  case 'mov':
                    svgIcon = SvgPicture.asset('assets/icons/mov.svg', color: Colors.white);
                    break;
                  case 'mp3':
                    svgIcon = SvgPicture.asset('assets/icons/mp3.svg', color: Colors.white);
                    break;
                  case 'mp4':
                    svgIcon = SvgPicture.asset('assets/icons/mp4.svg', color: Colors.white);
                    break;
                  case 'pdf':
                    svgIcon = SvgPicture.asset('assets/icons/pdf.svg', color: Colors.white);
                    break;
                  case 'png':
                    svgIcon = SvgPicture.asset('assets/icons/png.svg', color: Colors.white);
                    break;
                  case 'ppt':
                    svgIcon = SvgPicture.asset('assets/icons/ppt.svg', color: Colors.white);
                    break;
                  case 'pptx':
                    svgIcon = SvgPicture.asset('assets/icons/pptx.svg', color: Colors.white);
                    break;
                  case 'psd':
                    svgIcon = SvgPicture.asset('assets/icons/psd.svg', color: Colors.white);
                    break;
                  case 'txt':
                    svgIcon = SvgPicture.asset('assets/icons/txt.svg', color: Colors.white);
                    break;
                  case 'xls':
                    svgIcon = SvgPicture.asset('assets/icons/xls.svg', color: Colors.white);
                    break;
                  case 'xlsx':
                    svgIcon = SvgPicture.asset('assets/icons/xlsx.svg', color: Colors.white);
                    break;
                  case 'zip':
                    svgIcon = SvgPicture.asset('assets/icons/zip.svg', color: Colors.white);
                    break;
                  default:
                    svgIcon = SvgPicture.asset('assets/icons/txt.svg', color: Colors.white);
                }
                return Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 50, height: 30, child: svgIcon!),
                      //Materials Label
                      Expanded(
                        child: Text(
                          '${item.label}.${item.type} (${item.size})',
                          style: TextStyle(
                            color: HexColor.fromHex("#FFFFFF"),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: isLoading
                            ? () {
                                log('1'.toString());
                              }
                            : () async {
                                var cyrillicSymbols = RegExp('[а-яёА-ЯЁ]');
                                bool isSymbols = cyrillicSymbols.hasMatch(item.url);
                                String? dir;

                                if (Platform.isAndroid) {
                                  dir = (await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS));
                                } else if (Platform.isIOS) {
                                  dir = (await getApplicationDocumentsDirectory()).path;
                                }

                                if (item.url.toString().contains('jpeg') || item.url.toString().contains('png') || item.url.toString().contains('jpg')) {
                                  if (Platform.isIOS && isSymbols) {
                                    AlertDialog alert = AlertDialog(
                                      title: Text('Error image', textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
                                      content: Text(
                                        "Photo format error",
                                        textScaleFactor: 1.0,
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          child: Text(
                                            'Ok',
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                          ),
                                        )
                                      ],
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      },
                                    );
                                  } else {
                                    setState(() {
                                      isLoadingImg = true;
                                      progressMapImg!['item_url'] = item.url;
                                    });

                                    var imageId = await ImageDownloader.downloadImage(item.url);

                                    if (imageId == null) {
                                      return print('Error');
                                    }
                                  }
                                } else {
                                  setState(() {
                                    isLoading = true;
                                    progressMap!['item_url'] = item.url;
                                  });

                                  String fileName = item.url.substring(item.url.lastIndexOf("/") + 1);

                                  String fullPath = dir! + '/$fileName';

                                  Response response = await dio.get(
                                    item.url,
                                    onReceiveProgress: (received, total) {
                                      setState(() {
                                        progress = ((received / total * 100).toStringAsFixed(0) + '%');
                                      });
                                      progressMap!.addParam('progress', progress);
                                    },

                                    //Received data with List<int>
                                    options: Options(
                                      responseType: ResponseType.bytes,
                                      followRedirects: false,
                                    ),
                                  );

                                  File file = File(fullPath);
                                  var raf = file.openSync(mode: FileMode.write);
                                  raf.writeFromSync(response.data);
                                  await raf.close();

                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                        icon: isLoadingImg && item.url == progressMapImg!['item_url'] || isLoading && item.url == progressMap!['item_url']
                            ? SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                _progressImg == 100 && item.url == progressMapImg!['item_url'] || progress == '${100}%' && item.url == progressMap!['item_url'] ? Icons.check : Icons.download,
                                color: Colors.white,
                              ),
                      ),
                    ],
                  ),
                );
              }),
        )

        // if (_connectionStatus == ConnectivityResult.wifi || _connectionStatus == ConnectivityResult.mobile) _buildMaterialsContent(state) else SizedBox(),
      ],
    );
  }

  ///Materials Content
  _buildMaterialsContent(state) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Materials "Text"
          Text(
            localizations!.getLocalization("materials"),
            textScaleFactor: 1.0,
            style: TextStyle(color: HexColor.fromHex("#FFFFFF"), fontSize: 34, fontWeight: FontWeight.w700),
          ),
          //Materials
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: state.lessonResponse.materials.length,
              itemBuilder: (BuildContext ctx, int index) {
                var item = state.lessonResponse.materials[index];
                switch (item!.type) {
                  case 'audio':
                    svgIcon = SvgPicture.asset('assets/icons/audio.svg', color: Colors.white);
                    break;
                  case 'avi':
                    svgIcon = SvgPicture.asset('assets/icons/avi.svg', color: Colors.white);
                    break;
                  case 'doc':
                    svgIcon = SvgPicture.asset('assets/icons/doc.svg', color: Colors.white);
                    break;
                  case 'docx':
                    svgIcon = SvgPicture.asset('assets/icons/docx.svg', color: Colors.white);
                    break;
                  case 'gif':
                    svgIcon = SvgPicture.asset('assets/icons/gif.svg', color: Colors.white);
                    break;
                  case 'jpeg':
                    svgIcon = SvgPicture.asset('assets/icons/jpeg.svg', color: Colors.white);
                    break;
                  case 'jpg':
                    svgIcon = SvgPicture.asset('assets/icons/jpg.svg', color: Colors.white);
                    break;
                  case 'mov':
                    svgIcon = SvgPicture.asset('assets/icons/mov.svg', color: Colors.white);
                    break;
                  case 'mp3':
                    svgIcon = SvgPicture.asset('assets/icons/mp3.svg', color: Colors.white);
                    break;
                  case 'mp4':
                    svgIcon = SvgPicture.asset('assets/icons/mp4.svg', color: Colors.white);
                    break;
                  case 'pdf':
                    svgIcon = SvgPicture.asset('assets/icons/pdf.svg', color: Colors.white);
                    break;
                  case 'png':
                    svgIcon = SvgPicture.asset('assets/icons/png.svg', color: Colors.white);
                    break;
                  case 'ppt':
                    svgIcon = SvgPicture.asset('assets/icons/ppt.svg', color: Colors.white);
                    break;
                  case 'pptx':
                    svgIcon = SvgPicture.asset('assets/icons/pptx.svg', color: Colors.white);
                    break;
                  case 'psd':
                    svgIcon = SvgPicture.asset('assets/icons/psd.svg', color: Colors.white);
                    break;
                  case 'txt':
                    svgIcon = SvgPicture.asset('assets/icons/txt.svg', color: Colors.white);
                    break;
                  case 'xls':
                    svgIcon = SvgPicture.asset('assets/icons/xls.svg', color: Colors.white);
                    break;
                  case 'xlsx':
                    svgIcon = SvgPicture.asset('assets/icons/xlsx.svg', color: Colors.white);
                    break;
                  case 'zip':
                    svgIcon = SvgPicture.asset('assets/icons/zip.svg', color: Colors.white);
                    break;
                  default:
                    svgIcon = SvgPicture.asset('assets/icons/txt.svg', color: Colors.white);
                }
                return Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 50, height: 30, child: svgIcon!),
                      //Materials Label
                      Expanded(
                        child: Text(
                          '${item.label}.${item.type} (${item.size})',
                          style: TextStyle(
                            color: HexColor.fromHex("#FFFFFF"),
                            fontSize: 14,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: isLoading
                            ? () {
                                log('1'.toString());
                              }
                            : () async {
                                var cyrillicSymbols = RegExp('[а-яёА-ЯЁ]');
                                bool isSymbols = cyrillicSymbols.hasMatch(item.url);
                                String? dir;

                                if (Platform.isAndroid) {
                                  dir = (await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS));
                                } else if (Platform.isIOS) {
                                  dir = (await getApplicationDocumentsDirectory()).path;
                                }

                                if (item.url.toString().contains('jpeg') || item.url.toString().contains('png') || item.url.toString().contains('jpg')) {
                                  if (Platform.isIOS && isSymbols) {
                                    AlertDialog alert = AlertDialog(
                                      title: Text('Error image', textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
                                      content: Text(
                                        "Photo format error",
                                        textScaleFactor: 1.0,
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          child: Text(
                                            'Ok',
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                          ),
                                        )
                                      ],
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      },
                                    );
                                  } else {
                                    setState(() {
                                      isLoadingImg = true;
                                      progressMapImg!['item_url'] = item.url;
                                    });

                                    var imageId = await ImageDownloader.downloadImage(item.url);

                                    if (imageId == null) {
                                      return print('Error');
                                    }
                                  }
                                } else {
                                  setState(() {
                                    isLoading = true;
                                    progressMap!['item_url'] = item.url;
                                  });

                                  String fileName = item.url.substring(item.url.lastIndexOf("/") + 1);

                                  String fullPath = dir! + '/$fileName';

                                  Response response = await dio.get(
                                    item.url,
                                    onReceiveProgress: (received, total) {
                                      setState(() {
                                        progress = ((received / total * 100).toStringAsFixed(0) + '%');
                                      });
                                      progressMap!.addParam('progress', progress);
                                    },

                                    //Received data with List<int>
                                    options: Options(
                                      responseType: ResponseType.bytes,
                                      followRedirects: false,
                                    ),
                                  );

                                  File file = File(fullPath);
                                  var raf = file.openSync(mode: FileMode.write);
                                  raf.writeFromSync(response.data);
                                  await raf.close();

                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                        icon: isLoadingImg && item.url == progressMapImg!['item_url'] || isLoading && item.url == progressMap!['item_url']
                            ? SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                _progressImg == 100 && item.url == progressMapImg!['item_url'] || progress == '${100}%' && item.url == progressMap!['item_url'] ? Icons.check : Icons.download,
                                color: Colors.white,
                              ),
                      ),
                    ],
                  ),
                );
              })
        ],
      ),
    );
  }

  ///Bottom Button
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
                        onPressed: () async {
                          var connectivityResult = await (Connectivity().checkConnectivity());

                          ///If user connect to mobile or wifi
                          if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                            if (state is LoadedLessonVideoState && !state.lessonResponse.completed) {
                              _bloc.add(CompleteLessonEvent(widget.courseId, widget.lessonId));
                              setState(() {
                                completed = true;
                              });
                            }
                          } else {
                            if (preferences!.getString('textLessonComplete') != null) {
                              var existRecord = jsonDecode(preferences!.getString('textLessonComplete'));

                              for (var el in existRecord) {
                                if (el.toString().contains('added') && el['lesson_id'] == widget.lessonId) {
                                  print('exist');
                                } else {
                                  recordMap.add({
                                    'course_id': widget.courseId,
                                    'lesson_id': widget.lessonId,
                                    'added': 1,
                                  });

                                  preferences!.setString('textLessonComplete', jsonEncode(recordMap));

                                  setState(() {
                                    completed = true;
                                  });
                                }
                              }
                            } else {
                              recordMap.add({
                                'course_id': widget.courseId,
                                'lesson_id': widget.lessonId,
                                'added': 1,
                              });

                              preferences!.setString('textLessonComplete', jsonEncode(recordMap));
                              setState(() {
                                completed = true;
                              });
                            }
                          }
                        },
                        child: _buildButtonChild(state))),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: FlatButton(
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0), side: BorderSide(color: mainColor!)),
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
              localizations!.getLocalization("complete_lesson_button"),
              textScaleFactor: 1.0,
            ),
          )
        ],
      );
    }
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log(e.toString());
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
}
